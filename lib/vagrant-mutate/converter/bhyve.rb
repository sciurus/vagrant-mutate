require 'erb'

module VagrantMutate
  module Converter
    class Bhyve < Converter
      def generate_metadata
        {
          "provider" => @output_box.provider_name,
          "firmware" => "bios",
          "loader"   => "bhyveload"
        }
      end

      def generate_vagrantfile

        <<-EOF
        config.vm.provider :bhyve do |vm|
          vm.memory = "512M"
          vm.cpus = "1"
        end
        EOF
      end

      def write_specific_files
        # nothing yet
      end

    end
  end
end
