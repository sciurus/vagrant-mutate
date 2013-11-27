module VagrantMutate
  module Provider
    class Kvm < Provider
      def initialize
          @name             = 'kvm'
          @supported_input  = false,
          @supported_output = true,
          @image_format     = 'raw',
          @image_name       = 'box-disk1.img'
      end

      def generate_metadata(input_box, output_box)
        metadata = {
          'provider' => output_box.provider.name,
        }
      end

      def write_specific_files(input_box, output_box)
        # here we will write box.xml
      end

    end
  end
end
