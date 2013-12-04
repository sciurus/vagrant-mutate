require 'archive/tar/minitar'
require 'fileutils'
require 'json'
require 'zlib'

module VagrantMutate
  class BoxLoader

    include Archive::Tar

    def initialize( env )
      @env = env
      @logger = Log4r::Logger.new('vagrant::mutate')
      @tmp_dir = nil
    end

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

    def prepare_for_output(name, provider_name)
      @logger.info "Preparing #{name} for output as #{provider_name}"
      dir = create_output_dir(name, provider_name)
      box = create_box(provider_name, name, dir)

      unless box.supported_output
        raise Errors::ProviderNotSupported, :provider => provider_name, :direction => 'output'
      end

      return box
    end

    def load_from_file(file)
      @logger.info "Loading box from file #{file}"
      name = File.basename( file, File.extname(file) )
      dir = unpack(file)
      @tmp_dir = dir
      provider_name = determine_provider(dir)
      box = create_box(provider_name, name, dir)

      unless box.supported_input
        raise Errors::ProviderNotSupported, :provider => provider_name, :direction => 'input'
      end

      return box
    end

    def load_by_name(name)
      @logger.info "Loading box from name #{name}"
      dir = find_input_dir(name)
      # cheat for now since only supported input is virtualbox
      box = create_box('virtualbox', name, dir)
      return box
    end

    def cleanup
      if @tmp_dir
        @env.ui.info "Cleaning up temporary files."
        @logger.info "Deleting #{@tmp_dir}"
        FileUtils.remove_entry_secure(@tmp_dir)
      end
    end

    private

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

    def find_input_dir(name)
      # cheat for now since only supported input is virtualbox
      in_dir = File.join( @env.boxes_path, name, 'virtualbox' )
      if File.directory?(in_dir)
        @logger.info "Found input directory #{in_dir}"
        return in_dir
      else
        raise Errors::BoxNotFound, :box => in_dir
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
      # box may or may not be gzipped
      begin
        tar = Zlib::GzipReader.new(File.open(file, 'rb'))
      rescue
        tar = file
      end
      begin
        tmp_dir = Dir.mktmpdir
        Minitar.unpack(tar, tmp_dir)
      rescue => e
        raise Errors::ExtractBoxFailed, :error_message => e.message
      end
      @logger.info "Unpacked box to #{tmp_dir}"
      return tmp_dir
    end

  end
end
