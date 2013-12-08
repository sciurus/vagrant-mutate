require 'erb'

module VagrantMutate
  module Converter
    class Kvm < Converter

      def generate_metadata
        metadata = {
          'provider' => @output_box.provider_name,
        }
      end

      def write_specific_files
        template_path = VagrantMutate.source_root.join('templates', 'kvm', 'box.xml.erb')
        template = File.read(template_path)

        uuid = nil
        gui = true
        disk_bus = 'virtio'

        image_type = @output_box.image_format
        disk = @output_box.image_name

        name = @input_box.name
        memory = @input_box.memory / 1024 # convert bytes to kib
        cpus = @input_box.cpus
        mac = @input_box.mac_address
        arch = @input_box.architecture

        qemu_bin = find_kvm

        File.open( File.join( @output_box.dir, 'box.xml'), 'w') do |f|
          f.write( ERB.new(template).result(binding) )
        end
      end

      private

      def find_kvm
        qemu_bin_list = [ '/usr/bin/qemu-system-x86_64',
                          '/usr/bin/qemu-system-i386',
                          '/usr/bin/qemu-kvm',
                          '/usr/bin/kvm' ]
        qemu_bin = qemu_bin_list.detect { |binary| File.exists? binary }
        unless qemu_bin
          raise Errors::QemuNotFound
        end
        return qemu_bin
      end

    end
  end
end
