module VagrantMutate

  class Converter

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

    def write_metadata(output_box)
      metadata = { 'provider' => output_box.provider }
      begin
        File.open( File.join( output_box.dir, 'metadata.json'), 'w') do |f|
          f.write( JSON.generate(metadata) )
        end
      rescue => e
        raise Errors::MetadataWriteError, :error_message => e.message
      end
    end

    def write_disk(input_box, output_box)
      begin
        # qemu-img invocation goes here
      rescue
      end
    end

    def convert(input_box, output_box)
      write_metadata(output_box)
      write_disk(input_box, output_box)
    end

  end
end
