require 'shellwords'

module VagrantMutate
  module Box
    class Box
      attr_reader :name, :dir, :version, :provider_name, :supported_input, :supported_output, :image_format, :image_name

      def initialize(env, name, version, dir)
        @env     = env
        @name    = name
        @dir     = dir
        @version = version
        @logger  = Log4r::Logger.new('vagrant::mutate')
      end

      def virtual_size
        extract_from_qemu_info(/(\d+) bytes/)
      end

      def verify_format
        format_found = extract_from_qemu_info(/file format: (\w+)/)
        unless format_found == @image_format
          @env.ui.warn "Expected input image format to be #{@image_format} but "\
            "it is #{format_found}. Attempting conversion anyway."
        end
      end

      def extract_from_qemu_info(expression)
        input_file = File.join(@dir, image_name).shellescape
        info = `qemu-img info #{input_file}`
        @logger.debug "qemu-img info output\n#{info}"
        if info =~ expression
          return Regexp.last_match[1]
        else
          fail Errors::QemuInfoFailed
        end
      end
    end
  end
end
