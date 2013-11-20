module VagrantMutate
  module Provider

    class Virtualbox < Provider
      def initialize(env)
          super
          @name             = 'virtualbox'
          @supported_input  = true,
          @supported_output = false,
          @image_format     = 'vmdk',
          @image_name       = 'box-disk1.vmdk'
      end
    end

  end
end

