require_relative 'box'
require 'nokogiri'

module VagrantMutate
  module Box
    class Kvm < Box
      def initialize(env, name, version, dir)
        super
        @provider_name    = 'kvm'
        @supported_input  = true
        @supported_output = true
        @image_format     = 'qcow2'
        @image_name       = 'box-disk1.img'
      end

      # TODO: implement these methods
      #  architecture, mac_address, cpus, memory
      #  to support converting to providers besides libvirt

      def disk_interface
        domain_file = File.join(@dir, 'box.xml')
        begin
          domain = File.open(domain_file) { |f| Nokogiri::XML(f) }
          domain.xpath("//*[local-name()='domain']/*[local-name()='devices']/*[local-name()='disk']/*[local-name()='target']").attribute('bus')
        rescue => e
          raise Errors::BoxAttributeError, error_message: e.message
        end
      end
    end
  end
end
