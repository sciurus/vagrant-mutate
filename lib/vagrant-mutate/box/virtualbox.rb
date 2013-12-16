require "rexml/document"
require_relative 'box'

module VagrantMutate
  module Box
    class Virtualbox < Box

      def initialize(env, name, dir)
        super
        @provider_name     = 'virtualbox'
        @supported_input  = true,
        @supported_output = false,
        @image_format     = 'vmdk',
        @image_name       = 'box-disk1.vmdk'
      end

      # the architecture is not defined in the ovf file,
      # we could try to guess from OSType
      # (https://www.virtualbox.org/browser/vbox/trunk/src/VBox/Main/include/ovfreader.h)
      # but if that is not set correctly we risk a 64-bit box not booting
      # because we try to run in 32-bit vm.
      # in contrast, running 32-bit box in a 64-bit vm should work.
      def architecture
        return 'x86_64'
      end

      # use mac from the first enabled nic
      def mac_address
        mac = nil

        ovf.elements.each("//vbox:Machine/Hardware//Adapter") do |ele|
          if ele.attributes['enabled'] == 'true'
            mac = format_mac( ele.attributes['MACAddress'] )
            break
          end
        end

        if mac
          return mac
        else
          raise Errors::BoxAttributeError, :error_message => 'Could not determine mac address'
        end
      end

      def cpus
        cpu_count = nil

        ovf.elements.each("//VirtualHardwareSection/Item") do |device|
          if device.elements["rasd:ResourceType"].text == '3'
            cpu_count = device.elements["rasd:VirtualQuantity"].text
          end
        end

        if cpu_count
          return cpu_count
        else
          raise Errors::BoxAttributeError, :error_message => 'Could not determine number of CPUs'
        end
      end

      def memory
        memory_in_bytes = nil

        ovf.elements.each("//VirtualHardwareSection/Item") do |device|
          if device.elements["rasd:ResourceType"].text == '4'
            memory_in_bytes = size_in_bytes(device.elements["rasd:VirtualQuantity"].text,
              device.elements["rasd:AllocationUnits"].text)
          end
        end

        if memory_in_bytes
          return memory_in_bytes
        else
          raise Errors::BoxAttributeError, :error_message => 'Could not determine amount of memory'
        end
      end

      def disk_interface
        controller_type = {}
        controller_used_by_disk = nil
        ovf.elements.each("//VirtualHardwareSection/Item") do |device|
          # when we find a controller, store its ID and type
          # when we find a disk, store the ID of the controller it is connected to
          case device.elements["rasd:ResourceType"].text
          when "5"
             controller_type[device.elements["rasd:InstanceID"].text] = 'ide'
           when "6"
             controller_type[device.elements["rasd:InstanceID"].text] = 'scsi'
           when "20"
             controller_type[device.elements["rasd:InstanceID"].text] = 'sata'
           when "17"
             controller_used_by_disk = device.elements["rasd:Parent"].text
          end
        end
        if controller_used_by_disk and controller_type[controller_used_by_disk]
          return controller_type[controller_used_by_disk]
        else
          raise Errors::BoxAttributeError, :error_message => 'Could not determine disk interface'
        end
      end

      private

      def ovf
        if @ovf
          return @ovf
        end

        ovf_file = File.join( @dir, 'box.ovf')
        begin
          @ovf = REXML::Document.new( File.read(ovf_file) )
        rescue => e
          raise Errors::BoxAttributeError, :error_message => e.message
        end
      end

      # convert to more standard format with colons
      def format_mac(mac)
        mac.scan(/(.{2})/).join(':')
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

    end

  end
end
