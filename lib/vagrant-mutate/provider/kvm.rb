require 'erb'

module VagrantMutate
  module Provider
    class Kvm < Provider
      def initialize(box)
          @box              = box
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

        uuid = nil
        gui = true
        disk_bus = 'virtio'
        name = input_box.name
        image_type = @image_format
        disk = @image_name
        qemu_bin = get_kvm_path
        memory = input_box.provider.get_memory / 1024 # convert bytes to kib
        cpus = input_box.provider.get_cpus
        mac = input_box.provider.get_mac_address
        arch = input_box.provider.get_arch

        File.open( File.join( output_box.dir, 'box.xml'), 'w') do |f|
          f.write( ERB.new(template).result(binding) )
        end
      end

      def get_kvm_path
        qemu_bin_list = [ '/usr/bin/qemu-kvm', '/usr/bin/kvm',
                          '/usr/bin/qemu-system-x86_64',
                          '/usr/bin/qemu-system-i386' ]
        qemu_bin = qemu_bin_list.detect { |binary| File.exists? binary }
        unless qemu_bin
          raise Errors::QemuNotFound
        end
        return qemu_bin
      end

      private :get_kvm_path

    end
  end
end
