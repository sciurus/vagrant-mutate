require 'archive/tar/minitar'
require 'json'
require 'zlib'

module VagrantMutate

  class Converter

    include Archive::Tar

    # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
    def initialize(env)
      @env = env
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "qemu-img#{ext}")
          return if File.executable? exe
        end
      end
      # if we make it here qemu-img command was not found
      raise Errors::QemuNotFound
    end

    def unpack_box(box_file)
      unless File.exists? box_file
        raise Errors::BoxFileNotFound, :box => box_file
      end

      # box may or may not be gzipped
      begin
        tar = Zlib::GzipReader.new(File.open(box_file, 'rb'))
      rescue
        tar = box_file
      end

      begin
        box_dir = Dir.mktmpdir
        Minitar.unpack(tar, box_dir)
      rescue => e
        raise Errors::ExtractBoxFailed, :error_message => e.message
      end

      return box_dir
    end

    def determine_provider(box_dir)
      begin
        metadata = JSON.load( File.new( File.join(box_dir, 'metadata.json'), 'r') )
      rescue => e
        raise Errors::DetermineProviderFailed, :error_message => e.message
      end
      return metadata['provider']
    end

    def write_metadata(dir, provider)
      metadata = { 'provider' => provider }
      begin
        File.open( File.join( dir, 'metadata.json'), 'w') do |f|
          f.write( JSON.generate(metadata) )
        end
      rescue => e
        raise Errors::MetadataWriteError, :error_message => e.message
      end
    end

    def write_disk(box_dir, input_provider, output_provider)
      begin
        # qemu-img invocation goes here
      rescue
      end
    end

    def package_box(box_dir, box_name)
      begin
        # tar it up
      rescue
      end
    end

    def cleanup(dir)
      @env.ui.info('Cleaning up temporary files')
      FileUtils.remove_entry_secure(dir)
      @env.ui.info('Cleanup done')
    end

    def convert(input_box_dir, input_provider, output_provider, box_name)
      output_box_dir = Dir.mktmpdir
      write_metadata(output_box_dir, output_provider)
      write_disk(output_box_dir, input_provider, output_provider)
      package_box(output_box_dir, box_name)
      cleanup(output_box_dir)
    end

  end
end
