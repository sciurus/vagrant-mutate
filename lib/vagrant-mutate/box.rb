require 'archive/tar/minitar'
require 'fileutils'
require 'json'
require 'zlib'

module VagrantMutate
  class Box

    include Archive::Tar

    attr_reader :dir, :name, :provider

    def initialize( env )
      @env = env
      @logger = Log4r::Logger.new('vagrant::mutate')
    end

    def prepare_for_output( box_name, provider_name )
      @logger.info "Preparing #{box_name} for output as #{provider_name}"
      @name = box_name
      @provider = Provider::Provider.create( provider_name, @env )
      @dir = create_output_dir()
      @dir_is_tmp = false

      unless @provider.supported_output
        raise Errors::ProviderNotSupported, :provider => provider_name, :direction => 'output'
      end
    end

    def load_from_file(file)
      @logger.info "Loading box from file #{file}"
      @name = File.basename( file, File.extname(file) )
      @dir = unpack(file)
      @dir_is_tmp = true
      @provider = determine_provider()

      unless @provider.supported_input
        raise Errors::ProviderNotSupported, :provider => provider_name, :direction => 'input'
      end
    end

    def load_by_name(name)
      @logger.info "Loading box from name #{name}"
      @name = name
      # cheat for now since only supported input is virtualbox
      @provider = Provider::Provider.create('virtualbox', @env)
      @dir = find_input_dir()
      @dir_is_tmp = false
    end

    def cleanup
      if @dir_is_tmp
        @env.ui.info "Cleaning up temporary files."
        @logger.info "Deleting #{dir}"
        FileUtils.remove_entry_secure(@dir)
      end
    end

    def determine_provider
      metadata_file = File.join(@dir, 'metadata.json')
      if File.exists? metadata_file
        begin
          metadata = JSON.load( File.new( metadata_file, 'r') )
        rescue => e
          raise Errors::DetermineProviderFailed, :error_message => e.message
        end
        @logger.info "Determined input provider is #{metadata['provider']}"
        return Provider::Provider.create( metadata['provider'], @env )
      else
        @logger.info "No metadata found, so assuming input provider is virtualbox"
        return Provider::Provider.create('virtualbox')
      end
    end

    def find_input_dir
      in_dir = File.join( @env.boxes_path, @name, 'virtualbox' )
      if File.directory?(in_dir)
        @logger.info "Found input directory #{in_dir}"
        return in_dir
      else
        raise Errors::BoxNotFound, :box => in_dir
      end
    end

    def create_output_dir
      # e.g. $HOME/.vagrant.d/boxes/fedora-19/libvirt
      out_dir = File.join( @env.boxes_path, @name, @provider.name )
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
