require_relative 'box'

module VagrantMutate
  module Box
    class Kvm < Box

      def initialize(env, name, dir)
        super
        @provider_name    = 'kvm'
        @supported_input  = false
        @supported_output = true
        @image_format     = 'qcow2'
        @image_name       = 'box-disk1.img'
      end

    end
  end
end
