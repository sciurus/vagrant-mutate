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
        ovf.elements.each("//vbox:Machine/Hardware//Adapter") do |ele|
          if ele.attributes['enabled'] == 'true'
            mac = ele.attributes['MACAddress']
            # convert to more standarad format with colons
            return mac[0..1] + ":" + mac[2..3] + ":" +
              mac[4..5] + ":" + mac[6..7] + ":" +
              mac[8..9] + ":" + mac[10..11]
          end
        end
      end

      def cpus
        ovf.elements.each("//VirtualHardwareSection/Item") do |device|
          if device.elements["rasd:ResourceType"].text == '3'
            return device.elements["rasd:VirtualQuantity"].text
          end
        end
      end

      def memory
        ovf.elements.each("//VirtualHardwareSection/Item") do |device|
          if device.elements["rasd:ResourceType"].text == '4'
            return size_in_bytes(device.elements["rasd:VirtualQuantity"].text,
              device.elements["rasd:AllocationUnits"].text)
          end
        end
      end

      def disk_interface
        disk_contoller = {}
        disk_type = nil
        ovf.elements.each("//VirtualHardwareSection/Item") do |device|
          case device.elements["rasd:ResourceType"].text
          when "5"
             # IDE controller
             disk_contoller[device.elements["rasd:InstanceID"].text] = 'ide'
           when "6"
             # SCSI controller
             disk_contoller[device.elements["rasd:InstanceID"].text] = 'scsi'
           when "17"
             # Disk
             disk_type = device.elements["rasd:Parent"].text
           when "20"
             # SATA controller
             disk_contoller[device.elements["rasd:InstanceID"].text] = 'sata'
          end
        end
        disk_contoller[disk_type] if disk_type
      end

      private

      def ovf
        @ovf ||= REXML::Document.new( File.read( File.join( @dir, 'box.ovf') ) )
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
