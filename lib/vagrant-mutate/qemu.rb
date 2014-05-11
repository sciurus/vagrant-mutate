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
          installed_version = Gem::Version.new($1)
          # less than 1.2 or equal to 1.6.x
          if (installed_version < Gem::Version.new('1.2.0') or (installed_version >= Gem::Version.new('1.6.0') and installed_version < Gem::Version.new('1.7.0')))

            env.ui.warn "You have qemu #{installed_version} installed. "\
              "This version cannot read some virtualbox boxes. "\
              "If conversion fails, see below for recommendations. "\
              "https://github.com/sciurus/vagrant-mutate/wiki/QEMU-Version-Compatibility"

          end
        else
          raise Errors::ParseQemuVersionFailed
        end
      end

  end
end
