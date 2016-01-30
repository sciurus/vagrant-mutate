require_relative 'box'

module VagrantMutate
  module Box
    class Libvirt < Box
      def initialize(env, name, version, dir, force_virtio)
        super
        @provider_name    = 'libvirt'
        @supported_input  = true
        @supported_output = true
        @image_format     = 'qcow2'
        @image_name       = 'box.img'
        @mac              = nil
        @force_virtio     = force_virtio
      end

      # since none of below can be determined from the box
      # we just generate sane values

      def architecture
        'x86_64'
      end

      # kvm prefix is 52:54:00
      def mac_address
        unless @mac
          octets = 3.times.map { rand(255).to_s(16) }
          @mac = "525400#{octets[0]}#{octets[1]}#{octets[2]}"
        end
        @mac
      end

      def cpus
        1
      end

      def memory
        536_870_912
      end

      def disk_interface
        'virtio'
      end

      def force_virtio
        @force_virtio
      end

    end
  end
end
