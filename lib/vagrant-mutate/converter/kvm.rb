require 'erb'

module VagrantMutate
  module Converter
    class Kvm < Converter
      def generate_metadata
        { 'provider' => @output_box.provider_name }
      end

      def generate_vagrantfile
        "  config.vm.base_mac = '#{@input_box.mac_address}'"
      end

      def write_specific_files
        template_path = VagrantMutate.source_root.join('templates', 'kvm', 'box.xml.erb')
        template = File.read(template_path)

        uuid = nil
        gui = true

        if @force_virtio == true
          disk_bus = 'virtio'
        else
          disk_bus = @input_box.disk_interface
        end

        image_type = @output_box.image_format
        disk = @output_box.image_name

        name = @input_box.name
        memory = @input_box.memory / 1024 # convert bytes to kib
        cpus = @input_box.cpus
        mac = format_mac(@input_box.mac_address)
        arch = @input_box.architecture

        qemu_bin = find_kvm

        File.open(File.join(@output_box.dir, 'box.xml'), 'w') do |f|
          f.write(ERB.new(template).result(binding))
        end
      end

      private

      def find_kvm
        qemu_bin_list = ['/usr/bin/qemu-system-x86_64',
                         '/usr/bin/qemu-system-i386',
                         '/usr/bin/qemu-kvm',
                         '/usr/libexec/qemu-kvm',
                         '/usr/bin/kvm']
        qemu_bin = qemu_bin_list.find { |binary| File.exist? binary }
        unless qemu_bin
          fail Errors::QemuNotFound
        end
        qemu_bin
      end

      # convert to format with colons
      def format_mac(mac)
        mac.scan(/(.{2})/).join(':')
      end
    end
  end
end
