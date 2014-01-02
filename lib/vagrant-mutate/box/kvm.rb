require_relative 'box'

module VagrantMutate
  module Box
    class Kvm < Box

      def initialize(env, name, dir)
        super
        @provider_name    = 'kvm'
        @supported_input  = true
        @supported_output = true
        @image_format     = 'qcow2'
        @image_name       = 'box-disk1.img'
      end

      # TODO implement these methods
      # architecture, mac_address, cpus, memor, disk_interface
      # to support converting to providers besides libvirt

    end
  end
end
