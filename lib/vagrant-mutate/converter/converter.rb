require 'fileutils'

module VagrantMutate
  module Converter
    class Converter

      def self.create(env, input_box, output_box)
        case output_box.provider_name
        when 'kvm'
          require_relative 'kvm'
          Kvm.new(env, input_box, output_box)
        when 'libvirt'
          require_relative 'libvirt'
          Libvirt.new(env, input_box, output_box)
        else
          raise Errors::ProviderNotSupported, :provider => output_box.provider_name, :direction => 'output'
        end
      end

      def initialize(env, input_box, output_box)
        @env = env
        @input_box  = input_box
        @output_box = output_box
        @logger = Log4r::Logger.new('vagrant::mutate')
      end

      def convert()
        if @input_box.provider_name == @output_box.provider_name
          raise Errors::ProvidersMatch
        end

        @env.ui.info "Converting #{@input_box.name} from #{@input_box.provider_name} "\
          "to #{@output_box.provider_name}."

        @input_box.verify_format
        write_metadata
        write_vagrantfile
        write_specific_files
        write_disk
      end

      private

      def write_metadata
        metadata = generate_metadata
        begin
          File.open( File.join( @output_box.dir, 'metadata.json'), 'w') do |f|
            f.write( JSON.generate(metadata) )
          end
        rescue => e
          raise Errors::WriteMetadataFailed, :error_message => e.message
        end
        @logger.info "Wrote metadata"
      end

      def write_vagrantfile
        body = generate_vagrantfile
        begin
          File.open( File.join( @output_box.dir, 'Vagrantfile'), 'w') do |f|
            f.puts( 'Vagrant.configure("2") do |config|' )
            f.puts( body )
            f.puts( 'end' )
          end
        rescue => e
          raise Errors::WriteVagrantfileFailed, :error_message => e.message
        end
        @logger.info "Wrote vagrantfile"
      end

      def write_disk
        if @input_box.image_format == @output_box.image_format
          copy_disk
        else
          convert_disk
        end
      end

      def copy_disk
        input = File.join( @input_box.dir, @input_box.image_name )
        output = File.join( @output_box.dir, @output_box.image_name )
        @logger.info "Copying #{input} to #{output}"
        begin
          FileUtils.copy_file(input, output)
        rescue => e
          raise Errors::WriteDiskFailed, :error_message => e.message
        end
      end

      def convert_disk
        input_file    = File.join( @input_box.dir, @input_box.image_name )
        output_file   = File.join( @output_box.dir, @output_box.image_name )
        input_format  = @input_box.image_format
        output_format = @output_box.image_format

        # p for progress bar
        # S for sparse file
        qemu_options = '-p -S 16k'

        command = "qemu-img convert #{qemu_options} -O #{output_format} #{input_file} #{output_file}"
        @logger.info "Running #{command}"
        unless system(command)
          raise Errors::WriteDiskFailed, :error_message => "qemu-img exited with status #{$?.exitstatus}"
        end
      end

    end
  end
end
