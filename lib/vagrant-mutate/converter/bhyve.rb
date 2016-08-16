require 'erb'

module VagrantMutate
  module Converter
    class Bhyve < Converter
      def generate_metadata

        output_name = File.join(@output_box.dir, @output_box.image_name).shellescape

        file_output = `file #{output_name}`

        if file_output.include? "GRUB"
         loader = "grub-bhyve"
        else
         loader = "bhyveload"
        end

        {
          "provider" => @output_box.provider_name,
        }
      end

      def generate_vagrantfile
        memory = @input_box.memory / 1024 / 1024 # convert bytes to mebibytes
        cpus = @input_box.cpus
        <<-EOF
        config.vm.provider :bhyve do |vm|
          vm.memory = "#{memory}M"
          vm.cpus = "#{cpus}"
        end
        EOF
      end

      def write_specific_files
        # nothing yet
      end

    end
  end
end
