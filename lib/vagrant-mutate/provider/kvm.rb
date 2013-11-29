require 'erb'

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
        template_path = VagrantMutate.source_root.join('templates', 'kvm', 'box.xml.erb')
        template = File.read(template_path)

        # for testing just arbitrarily setting these values
        uuid = nil
        gui = nil
        name = 'precise32'
        memory = 393216
        cpus = 1
        arch = 'i686'
        qemu_bin = '/usr/bin/qemu-kvm'
        image_type = @image_format
        disk = @image_name
        disk_bus = 'virtio'
        mac = '08:00:27:12:96:98'

        File.open( File.join( output_box.dir, 'box.xml'), 'w') do |f|
          f.write( ERB.new(template).result(binding) )
        end
      end

    end
  end
end
