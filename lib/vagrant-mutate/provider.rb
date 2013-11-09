module VagrantMutate
  module Provider

    class Provider
      attr_reader :name, :supported_input, :supported_output, :image_format, :image_name

      def self.create(name)
        case name
        when 'libvirt'
          Libvirt.new
        when 'virtualbox'
          Virtualbox.new
        else
          raise Errors::ProviderNotSupported, :provider => name, :direction => 'input or output'
        end
      end

    end

    class Libvirt < Provider
      def initialize
          @name             = 'libvirt'
          @supported_input  = true,
          @supported_output = true,
          @image_format     = 'qcow2',
          @image_name       = 'box.img'
      end
    end

    class Virtualbox < Provider
      def initialize
          @name             = 'virtualbox'
          @supported_input  = true,
          @supported_output = false,
          @image_format     = 'vmdk',
          @image_name       = 'box-disk1.vmdk'
      end
    end

  end
end
