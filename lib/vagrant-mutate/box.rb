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

    def prepare_for_output( name, provider )
      @logger.info "Preparing #{name} for output as #{provider}"
      @name = name
      @provider = provider
      @dir = create_output_dir()
      @dir_is_tmp = false
    end

    def load_from_file(file)
      @logger.info "Loading box from file #{file}"
      @name = file[0..-5]
      @dir = unpack(file)
      @dir_is_tmp = true
      @provider = determine_provider()
    end

    def load_by_name(name)
      @logger.info "Loading box from name #{name}"
      @name = name
      # cheat for now since only supported input is virtualbox
      @provider = 'virtualbox'
      @dir = find_input_dir()
      @dir_is_tmp = false
    end

    def cleanup
      if @dir_is_tmp
        @logger.info "Deleting #{dir}"
        FileUtils.remove_entry_secure(@dir)
      end
    end

    def determine_provider
      begin
        metadata = JSON.load( File.new( File.join(@dir, 'metadata.json'), 'r') )
      rescue => e
        raise Errors::DetermineProviderFailed, :error_message => e.message
      end
      @logger.info "Determined provider is #{metadata['provider']}"
      return metadata['provider']
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
      out_dir = File.join( @env.boxes_path, @name, @provider )
      begin
        FileUtils.mkdir_p(out_dir)
      rescue => e
        raise Errors::CreateBoxDirFailed, :error_message => e.message
      end
      @logger.info "Created output directory #{out_dir}"
      return out_dir
    end

    def unpack(file)
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
