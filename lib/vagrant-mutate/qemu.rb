module VagrantMutate
  class Qemu

      # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
      def self.verify_qemu_installed
        logger = Log4r::Logger.new('vagrant::mutate')
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
          exts.each do |ext|
            exe = File.join(path, "qemu-img#{ext}")
            if File.executable? exe
              logger.info "Found qemu"
              return
            end
          end
        end
        # if we make it here qemu-img command was not found
        raise Errors::QemuNotFound
      end

      def self.verify_qemu_version(env)
        usage = `qemu-img`
        if usage =~ /(\d+\.\d+\.\d+)/
          recommended_version = Gem::Version.new('1.2.0')
          installed_version = Gem::Version.new($1)
          if installed_version < recommended_version
            env.ui.warn "You have qemu #{installed_version} installed. "\
              "This version is too old to read some virtualbox boxes. "\
              "If conversion fails, try upgrading to qemu 1.2.0 or newer."
          end
        else
          raise Errors::ParseQemuVersionFailed
        end
      end

  end
end
