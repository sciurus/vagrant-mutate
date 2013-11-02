# This will be split into multiple classes; see https://github.com/sciurus/vagrant-mutate/issues/7

module VagrantMutate
  class Provider

    attr_reader :name, :supported_input, :supported_output, :image_format, :image_name

      def initialize(name)

        providers = {
          'libvirt' => {
            'supported_input'  => true,
            'supported_output' => true,
            'image_format'     => 'qcow2',
            'image_name'       => 'box.img'
          },
          'virtualbox' => {
            'supported_input'  => true,
            'supported_output' => false,
            'image_format'     => 'vmdk',
            'image_name'       => 'box-disk1.vmdk'
          }
        }

        unless providers.has_key? name
          raise Errors::ProviderNotSupported, :provider => name
        end

        @name = name
        @supported_input  = providers[name]['supported_input']
        @supported_output = providers[name]['supported_output']
        @image_format     = providers[name]['image_format']
        @image_name       = providers[name]['image_name']
    end

  end
end
