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
          'virtual_size' => ( input_box.determine_virtual_size.to_f / (1024 * 1024 * 1024) ).ceil
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

    end
  end
end
