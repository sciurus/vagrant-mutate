module VagrantMutate
  module Provider
    class Libvirt < Provider
      def initialize(env)
          super
          @name             = 'libvirt'
          @supported_input  = true,
          @supported_output = true,
          @image_format     = 'qcow2',
          @image_name       = 'box.img'
      end

      def convert(input_box, output_box)
        write_metadata(input_box, output_box)
        copy_vagrantfile(input_box, output_box)
        write_disk(input_box, output_box)
      end

      # maybe put generating metadata in specific class
      # and writing it in base class
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

      # move determining size in bytes from provider to box
      # and just adjust to gb in write_metadata
      def determine_virtual_size(input_box)
        input_file = File.join( input_box.dir, input_box.provider.image_name )
        info = `qemu-img info #{input_file}`
        @logger.info "qemu-img info output\n#{info}"
        if info =~ /(\d+) bytes/
          # vagrant-libvirt wants size in GB and as integer
          size_in_bytes = $1.to_f
          size_in_gb = size_in_bytes / (1024 * 1024 * 1024)
          rounded_size_in_gb = size_in_gb.ceil
          return rounded_size_in_gb
        else
          raise Errors::DetermineImageSizeFailed
        end
      end
    end
  end
end
