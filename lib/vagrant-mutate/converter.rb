require 'fileutils'

module VagrantMutate
  class Converter

    # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
    def initialize(env)
      @env = env
      @logger = Log4r::Logger.new('vagrant::mutate')
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "qemu-img#{ext}")
          if File.executable? exe
            @logger.info "Found qemu"
            return
          end
        end
      end
      # if we make it here qemu-img command was not found
      raise Errors::QemuNotFound
    end

    def write_metadata(output_box)
      metadata = { 'provider' => output_box.provider.name }
      begin
        File.open( File.join( output_box.dir, 'metadata.json'), 'w') do |f|
          f.write( JSON.generate(metadata) )
        end
      rescue => e
        raise Errors::WriteMetadataFailed, :error_message => e.message
      end
      @logger.info "Wrote metadata"
    end

    def write_disk(input_box, output_box)
      if input_box.provider.image_format == output_box.provider.image_format
        copy_disk(input_box, output_box)
      else
        convert_disk(input_box, output_box)
      end
    end

    def copy_disk(input_box, output_box)
        input = File.join( input_box.dir, input_box.provider.image_name )
        output = File.join( output_box.dir, output_box.provider.image_name )
        @logger.info "Copying #{input} to #{output}"
        begin
          FileUtils.copy_file(input, output)
        rescue => e
          raise Errors::WriteDiskFailed, :error_message => e.message
        end
    end

    def convert_disk(input_box, output_box)
        input = File.join( input_box.dir, input_box.provider.image_name )
        output = File.join( output_box.dir, output_box.provider.image_name )
        @logger.info "Converting #{input_box.provider.image_format} disk #{input} "\
          "to #{output_box.provider.image_format} disk #{output}"
      begin
        # qemu-img invocation goes here
      rescue => e
          raise Errors::WriteDiskFailed, :error_message => e.message
      end
    end

    def convert(input_box, output_box)
      @env.ui.info "Converting #{input_box.name} from #{input_box.provider.name} "\
        "to #{output_box.provider.name}. Please be patient..."
      write_metadata(output_box)
      write_disk(input_box, output_box)
    end

  end
end
