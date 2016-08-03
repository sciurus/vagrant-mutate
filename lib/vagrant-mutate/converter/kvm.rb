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
        qemu_bin = nil
        found = false

        qemu_bin_list = ['qemu-system-x86_64',
                         'qemu-system-i386',
                         'qemu-kvm',
                         'kvm']
        qemu_bin_list.each do |qemu|
          ENV["PATH"].split(":").each do |path|
            file_path = File.join(path, qemu)
            if File.exists?(file_path)
              qemu_bin = file_path
              found = true
              break
            end
          end
          if found == true
            break
          end
        end

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
