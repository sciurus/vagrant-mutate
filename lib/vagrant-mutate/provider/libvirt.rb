module VagrantMutate
  module Provider
    class Libvirt < Provider
      def initialize(box)
          @box              = box
          @name             = 'libvirt'
          @supported_input  = false,
          @supported_output = true,
          @image_format     = 'qcow2',
          @image_name       = 'box.img'
      end

      def generate_metadata(input_box)
        metadata = {
          'provider' => @box.provider.name,
          'format'   => 'qcow2',
          'virtual_size' => ( input_box.determine_virtual_size.to_f / (1024 * 1024 * 1024) ).ceil
        }
      end

    end
  end
end
