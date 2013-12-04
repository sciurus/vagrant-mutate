module VagrantMutate
  module Box
    class Box

      attr_reader :name, :dir, :provider_name, :supported_input, :supported_output, :image_format, :image_name

      def initialize(env, name, dir)
        @env = env
        @name = name
        @dir = dir
        @logger = Log4r::Logger.new('vagrant::mutate')
      end

      def virtual_size
        input_file = File.join( @dir, @image_name )
        info = `qemu-img info #{input_file}`
        @logger.debug "qemu-img info output\n#{info}"
        if info =~ /(\d+) bytes/
          return $1
        else
          raise Errors::DetermineImageSizeFailed
        end
      end

    end
  end
end
