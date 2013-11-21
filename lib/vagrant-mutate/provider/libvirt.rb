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

      def generate_metadata(input_box, output_box)
        metadata = {
          'provider' => output_box.provider.name,
          'format'   => 'qcow2',
          'virtual_size' => ( input_box.determine_virtual_size.to_f / (1024 * 1024 * 1024) ).ceil
        }
      end

    end
  end
end
