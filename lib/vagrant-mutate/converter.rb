require 'fileutils'

# This will be merged into providers; see https://github.com/sciurus/vagrant-mutate/issues/7

module VagrantMutate
  class Converter

    # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
    def initialize(env)
      @env = env
      @logger = Log4r::Logger.new('vagrant::mutate')
      verify_qemu_installed
      verify_qemu_version
    end

    def verify_qemu_installed
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

    def verify_qemu_version
      usage = `qemu-img`
      if usage =~ /(\d+\.\d+\.\d+)/
        recommended_version = Gem::Version.new('1.2.0')
        installed_version = Gem::Version.new($1)
        if installed_version < recommended_version
          @env.ui.warn "You have qemu #{installed_version} installed. "\
            "This version is too old to read some virtualbox boxes. "\
            "If conversion fails, try upgrading to qemu 1.2.0 or newer."
        end
      else
        raise Errors::ParseQemuVersionFailed
      end
    end

    def determine_virtual_size(input_box)
      input_file = File.join( input_box.dir, input_box.provider.image_name )
      info = `qemu-img info #{input_file}`
      @logger.info "qemu-img info output\n#{info}"
      if info =~ /(\d+) bytes/
        size_in_gb = $1.to_i / (1024 * 1024 * 1024)
        return size_in_gb
      else
        raise Errors::DetermineImageSizeFailed
      end
    end

    # This has some libvirt specific functionality at the moment
    def write_metadata(input_box, output_box)
      metadata = {
        'provider' => output_box.provider.name,
        'format'   => 'qcow2',
        'virtual_size' => determine_virtual_size(input_box)
      }
      begin
        File.open( File.join( output_box.dir, 'metadata.json'), 'w') do |f|
          f.write( JSON.generate(metadata) )
        end
      rescue => e
        raise Errors::WriteMetadataFailed, :error_message => e.message
      end
      @logger.info "Wrote metadata"
    end

    def write_vagrantfile(input_box, output_box)
      input = File.join( input_box.dir, 'Vagrantfile' )
      if File.exists? input
        output = File.join( output_box.dir, 'Vagrantfile' )
        @logger.info "Copying #{input} to #{output}"
        begin
          FileUtils.copy_file(input, output)
        rescue => e
          raise Errors::WriteVagrantfileFailed, :error_message => e.message
        end
      end
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
      input_file    = File.join( input_box.dir, input_box.provider.image_name )
      output_file   = File.join( output_box.dir, output_box.provider.image_name )
      input_format  = input_box.provider.image_format
      output_format = output_box.provider.image_format

      command = "qemu-img convert -p -f #{input_format} -O #{output_format} #{input_file} #{output_file}"
      @logger.info "Running #{command}"
      unless system(command)
        raise Errors::WriteDiskFailed, :error_message => "qemu-img exited with status #{$?.exitstatus}"
      end

    end

    def convert(input_box, output_box)
      @env.ui.info "Converting #{input_box.name} from #{input_box.provider.name} "\
        "to #{output_box.provider.name}."
      write_metadata(input_box, output_box)
      write_vagrantfile(input_box, output_box)
      write_disk(input_box, output_box)
    end

  end
end
