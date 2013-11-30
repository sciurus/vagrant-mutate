require "rexml/document"

module VagrantMutate
  module Provider

    class Virtualbox < Provider
      def initialize
          @name             = 'virtualbox'
          @supported_input  = true,
          @supported_output = false,
          @image_format     = 'vmdk',
          @image_name       = 'box-disk1.vmdk'
      end

      def parse_ovf(input_box)
        unless @ovf
          definition = File.read( File.join( input_box.dir, 'box.ovf') )
          @ovf = REXML::Document.new(definition)
        end
        @ovf
      end

      # the architecture is not defined in the ovf file,
      # we could try to guess from OSType
      # (https://www.virtualbox.org/browser/vbox/trunk/src/VBox/Main/include/ovfreader.h)
      # but if that is not set correctly we risk a 64-bit box not booting
      # because we try to run in 32-bit vm.
      # in contrast, running 32-bit box in a 64-bit vm should work.
      def get_arch
        return 'x86_64'
      end

      # use mac from the first enabled nic
      def get_mac_address
        @ovf.elements.each("//vbox:Machine/Hardware//Adapter") do |ele|
          if ele.attributes['enabled'] == 'true'
            mac = ele.attributes['MACAddress']
            # convert to more standarad format with colons
            return mac[0..1] + ":" + mac[2..3] + ":" +
              mac[4..5] + ":" + mac[6..7] + ":" +
              mac[8..9] + ":" + mac[10..11]
          end
        end
      end

      def get_cpus
        @ovf.elements.each("//VirtualHardwareSection/Item") do |device|
          if device.elements["rasd:ResourceType"].text == '3'
            return device.elements["rasd:VirtualQuantity"].text
          end
        end
      end

      def get_memory
        @ovf.elements.each("//VirtualHardwareSection/Item") do |device|
          if device.elements["rasd:ResourceType"].text == '4'
            return size_in_bytes(device.elements["rasd:VirtualQuantity"].text,
              device.elements["rasd:AllocationUnits"].text)
          end
        end
      end

      # Takes a quantity and a unit
      # returns quantity in bytes
      # mib = true to use mebibytes, etc
      # defaults to false because ovf MB != megabytes
      def size_in_bytes(qty, unit, mib=false)
        qty = qty.to_i
        unit = unit.downcase
        if !mib
          case unit
          when "kb", "kilobytes"
            unit = "kib"
          when "mb", "megabytes"
            unit = "mib"
          when "gb", "gigabytes"
            unit = "gib"
          end
        end
        case unit
        when "b", "bytes"
          qty
        when "kb", "kilobytes"
          (qty * 1000)
        when "kib", "kibibytes"
          (qty * 1024)
        when "mb", "megabytes"
          (qty * 1000000)
        when "m", "mib", "mebibytes"
          (qty * 1048576)
        when "gb", "gigabytes"
          (qty * 1000000000)
        when "g", "gib", "gibibytes"
          (qty * 1073741824)
        else
          raise ArgumentError, "Unknown unit #{unit}"
        end
      end

      private :size_in_bytes

    end

  end
end

