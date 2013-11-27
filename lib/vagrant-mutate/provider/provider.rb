module VagrantMutate
  module Provider
    class Provider
      attr_reader :name, :supported_input, :supported_output, :image_format, :image_name

      def self.create(name)
        case name
        when 'kvm'
          require_relative 'kvm'
          Kvm.new
        when 'libvirt'
          require_relative 'libvirt'
          Libvirt.new
        when 'virtualbox'
          require_relative 'virtualbox'
          Virtualbox.new
        else
          raise Errors::ProviderNotSupported, :provider => name, :direction => 'input or output'
        end
      end

    end
  end
end
