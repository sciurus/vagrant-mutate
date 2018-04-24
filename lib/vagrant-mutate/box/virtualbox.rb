require 'nokogiri'
require_relative 'box'

module VagrantMutate
  module Box
    class Virtualbox < Box
      def initialize(env, name, version, dir)
        super
        @provider_name    = 'virtualbox'
        @supported_input  = true
        @supported_output = false
        @image_format     = 'vmdk'
      end

      # this is usually box-disk1.vmdk but some tools like packer customize it
      def image_name
        ovf.xpath("//*[local-name()='References']/*[local-name()='File']")[0].attribute("href").value
      end

      # the architecture is not defined in the ovf file,
      # we could try to guess from OSType
      # (https://www.virtualbox.org/browser/vbox/trunk/src/VBox/Main/include/ovfreader.h)
      # but if that is not set correctly we risk a 64-bit box not booting
      # because we try to run in 32-bit vm.
      # in contrast, running 32-bit box in a 64-bit vm should work.
      def architecture
        'x86_64'
      end

      # use mac from the first enabled nic
      def mac_address
        mac = nil

        ovf.xpath("//*[local-name()='Machine']/*[local-name()='Hardware']/*[local-name()='Network']/*[local-name()='Adapter']").each do |net|
        if net.attribute("enabled").value == "true"
            mac = net.attribute("MACAddress").value
            break
          end
        end

        if mac
          return mac
        else
          fail Errors::BoxAttributeError, error_message: 'Could not determine mac address'
        end
      end

      def cpus
        cpu_count = nil

        ovf.xpath("//*[local-name()='VirtualHardwareSection']/*[local-name()='Item']/*[local-name()='ResourceType']").each do |item|
          if item.text == "3"
            cpu_count = item.parent.xpath("*[local-name()='VirtualQuantity']").text
          end
        end

        if cpu_count
          return cpu_count
        else
          fail Errors::BoxAttributeError, error_message: 'Could not determine number of CPUs'
        end
      end

      def memory
        memory_in_bytes = nil

        ovf.xpath("//*[local-name()='VirtualHardwareSection']/*[local-name()='Item']/*[local-name()='ResourceType']").each do |item|
          if item.text == "4"
            memory_in_bytes = size_in_bytes(item.parent.xpath("*[local-name()='VirtualQuantity']").text,
                                            item.parent.xpath("*[local-name()='AllocationUnits']").text)
          end
        end

        if memory_in_bytes
          return memory_in_bytes
        else
          fail Errors::BoxAttributeError, error_message: 'Could not determine amount of memory'
        end
      end

      def disk_interface
        controller_type = {}
        controller_used_by_disk = nil
        ovf.xpath("//*[local-name()='VirtualHardwareSection']/*[local-name()='Item']/*[local-name()='ResourceType']").each do |device|
          # when we find a controller, store its ID and type
          # when we find a disk, store the ID of the controller it is connected to
          case device.text
          when '5'
            controller_type[device.parent.xpath("*[local-name()='InstanceID']").text] = 'ide'
          when '6'
            controller_type[device.parent.xpath("*[local-name()='InstanceID']").text] = 'scsi'
          when '20'
            controller_type[device.parent.xpath("*[local-name()='InstanceID']").text] = 'sata'
          when '17'
            controller_used_by_disk = device.parent.xpath("*[local-name()='Parent']").text
          end
        end
        if controller_used_by_disk and controller_type[controller_used_by_disk]
          return controller_type[controller_used_by_disk]
        else
          fail Errors::BoxAttributeError, error_message: 'Could not determine disk interface'
        end
      end

      private

      def ovf
        if @ovf
          return @ovf
        end

        ovf_file = File.join(@dir, 'box.ovf')
        begin
          @ovf = File.open(ovf_file) { |f| Nokogiri::XML(f) }
        rescue => e
          raise Errors::BoxAttributeError, error_message: e.message
        end
      end

      # Takes a quantity and a unit
      # returns quantity in bytes
      # mib = true to use mebibytes, etc
      # defaults to false because ovf MB != megabytes
      def size_in_bytes(qty, unit, mib = false)
        qty = qty.to_i
        unit = unit.downcase.gsub(/\s+/, '')
        unless mib
          case unit
          when 'kb', 'kilobytes'
            unit = 'kib'
          when 'mb', 'megabytes'
            unit = 'mib'
          when 'gb', 'gigabytes'
            unit = 'gib'
          end
        end
        case unit
        when 'b', 'bytes'
          qty
        when 'kb', 'kilobytes'
          (qty * 1000)
        when 'kib', 'kibibytes', 'byte*2^10'
          (qty * 1024)
        when 'mb', 'megabytes'
          (qty * 1_000_000)
        when 'm', 'mib', 'mebibytes', 'byte*2^20'
          (qty * 1_048_576)
        when 'gb', 'gigabytes'
          (qty * 1_000_000_000)
        when 'g', 'gib', 'gibibytes', 'byte*2^30'
          (qty * 1_073_741_824)
        else
          fail ArgumentError, "Unknown unit #{unit}"
        end
      end
    end
  end
end
