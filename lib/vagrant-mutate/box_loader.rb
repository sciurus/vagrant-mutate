require 'fileutils'
require 'json'
require 'uri'
require "vagrant/util/subprocess"
require "vagrant/util/downloader"

module VagrantMutate
  class BoxLoader

    def initialize( env )
      @env = env
      @logger = Log4r::Logger.new('vagrant::mutate')
      @tmp_files = []
    end

    def prepare_for_output(name, provider_name)
      @logger.info "Preparing #{name} for output as #{provider_name}"
      dir = create_output_dir(name, provider_name)
      box = create_box(provider_name, name, dir)

      if box.supported_output
        return box
      else
        raise Errors::ProviderNotSupported, :provider => provider_name, :direction => 'output'
      end
    end

    def load(box_arg)
      if box_arg =~ /:\/\//
        box = load_from_url(box_arg)
      elsif box_arg =~ /\.box$/
        box = load_from_file(box_arg)
      else
        box = load_from_boxes_path(box_arg)
      end

      if box.supported_input
        return box
      else
        raise Errors::ProviderNotSupported, :provider => box.provider_name, :direction => 'input'
      end
    end

    def load_from_url(url)
      @logger.info "Loading box from url #{url}"

      # test that we have a valid url
      url = URI(url)
      unless url.scheme and url.host and url.path
        raise Errors::URLError, :url => url
      end

      # extract the name of the box from the url
      # if it ends in .box remove that extension
      # if not just remove leading slash
      name = nil
      if url.path =~ /(\w+).box$/
        name = $1
      else
        name = url.path.sub(/^\//, '')
      end
      if name.empty?
        raise Errors::URLError, :url => url
      end

      # using same path as in vagrants box add action
      download_path = File.join(@env.tmp_path, 'box' + Digest::SHA1.hexdigest(url.to_s))
      @tmp_files << download_path

      # if this fails it will raise an error and we'll quit
      @env.ui.info "Downloading box #{name} from #{url}"
      downloader = Vagrant::Util::Downloader.new(url, download_path, { :ui => @env.ui })
      downloader.download!

      dir = unpack(download_path)

      provider_name = determine_provider(dir)

      box = create_box(provider_name, name, dir)
    end

    def load_from_file(file)
      @logger.info "Loading box from file #{file}"
      name = File.basename( file, File.extname(file) )
      dir = unpack(file)
      provider_name = determine_provider(dir)

      box = create_box(provider_name, name, dir)
    end

    def load_from_boxes_path(identifier)
      @logger.info "Loading box #{identifier} from vagrants box path"
      provider_name, name = parse_identifier(identifier)
      if provider_name
        dir = verify_input_dir(provider_name, name)
      else
        provider_name, dir = find_input_dir(name)
      end
      box = create_box(provider_name, name, dir)
    end

    def cleanup
      unless @tmp_files.empty?
        @env.ui.info "Cleaning up temporary files."
        @tmp_files.each do |f|
          @logger.info "Deleting #{f}"
          FileUtils.remove_entry_secure(f)
        end
      end
    end

    private

    def create_box(provider_name, name, dir)
        @logger.info "Creating box #{name} with provider #{provider_name} in #{dir}"
        case provider_name
        when 'kvm'
          require_relative 'box/kvm'
          Box::Kvm.new(@env, name, dir)
        when 'libvirt'
          require_relative 'box/libvirt'
          Box::Libvirt.new(@env, name, dir)
        when 'virtualbox'
          require_relative 'box/virtualbox'
          Box::Virtualbox.new(@env, name, dir)
        else
          raise Errors::ProviderNotSupported, :provider => provider_name, :direction => 'input or output'
        end
    end

    def create_output_dir(name, provider_name)
      # e.g. $HOME/.vagrant.d/boxes/fedora-19/libvirt
      out_dir = File.join( @env.boxes_path, name, provider_name )
      begin
        FileUtils.mkdir_p(out_dir)
      rescue => e
        raise Errors::CreateBoxDirFailed, :error_message => e.message
      end
      @logger.info "Created output directory #{out_dir}"
      return out_dir
    end

    def unpack(file)
      @env.ui.info "Extracting box file to a temporary directory."
      unless File.exists? file
        raise Errors::BoxNotFound, :box => file
      end
      tmp_dir = Dir.mktmpdir(nil, @env.tmp_path)
      @tmp_files << tmp_dir
      result = Vagrant::Util::Subprocess.execute(
       "bsdtar", "-v", "-x", "-m", "-C", tmp_dir.to_s, "-f", file)
      if result.exit_code != 0
        raise Errors::ExtractBoxFailed, :error_message => result.stderr.to_s
      end
      @logger.info "Unpacked box to #{tmp_dir}"
      return tmp_dir
    end

    def determine_provider(dir)
      metadata_file = File.join(dir, 'metadata.json')
      if File.exists? metadata_file
        begin
          metadata = JSON.load( File.new( metadata_file, 'r') )
        rescue => e
          raise Errors::DetermineProviderFailed, :error_message => e.message
        end
        @logger.info "Determined input provider is #{metadata['provider']}"
        return metadata['provider']
      else
        @logger.info "No metadata found, so assuming input provider is virtualbox"
        return 'virtualbox'
      end
    end

    def parse_identifier(identifier)
      if identifier =~ /^([\w-]+)#{File::SEPARATOR}([\w-]+)$/
        @logger.info "Parsed provider name as #{$1} and box name as #{$2}"
        return $1, $2
      else
        @logger.info "Parsed provider name as not given and box name as #{identifier}"
        return nil, identifier
      end
    end

    def verify_input_dir(provider_name, name)
      input_dir = File.join( @env.boxes_path, name, provider_name)
      if File.directory?(input_dir)
        @logger.info "Found input directory #{input_dir}"
        return input_dir
      else
        raise Errors::BoxNotFound, :box => input_dir
      end
    end

    def find_input_dir(name)
      box_parent_dir = File.join( @env.boxes_path, name)

      if Dir.exist?(box_parent_dir)
        providers = Dir.entries(box_parent_dir).reject { |entry| entry =~ /^\./ }
        @logger.info "Found potential providers #{providers}"
      else
        providers = []
      end

      case
      when providers.length < 1
        raise Errors::BoxNotFound, :box => name
      when providers.length > 1
        raise Errors::TooManyBoxesFound, :box => name
      else
        provider_name = providers.first
        input_dir = File.join( box_parent_dir, provider_name)
        @logger.info "Found source for box #{name} from provider #{provider_name} at #{input_dir}"
        return provider_name, input_dir
      end
    end

  end
end
