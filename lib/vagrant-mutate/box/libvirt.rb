require_relative 'box'

module VagrantMutate
  module Box
    class Libvirt < Box

      def initialize(env, name, dir)
        super
        @provider_name    = 'libvirt'
        @supported_input  = false,
        @supported_output = true,
        @image_format     = 'qcow2',
        @image_name       = 'box.img'
      end

    end
  end
end
