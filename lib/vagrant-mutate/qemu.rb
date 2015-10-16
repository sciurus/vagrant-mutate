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
            logger.info 'Found qemu'
            return
          end
        end
      end
      # if we make it here qemu-img command was not found
      fail Errors::QemuImgNotFound
    end

    def self.qemu_version()
      usage = `qemu-img --version`
      if usage =~ /(\d+\.\d+\.\d+)/
        return Gem::Version.new(Regexp.last_match[1])
      else
        fail Errors::ParseQemuVersionFailed
      end
    end

    def self.verify_qemu_version(env)
      installed_version = qemu_version()
      # less than 1.2 or equal to 1.6.x
      if installed_version < Gem::Version.new('1.2.0') or (installed_version >= Gem::Version.new('1.6.0') and installed_version < Gem::Version.new('1.7.0'))

        env.ui.warn "You have qemu #{installed_version} installed. "\
          'This version cannot read some virtualbox boxes. '\
          'If conversion fails, see below for recommendations. '\
          'https://github.com/sciurus/vagrant-mutate/wiki/QEMU-Version-Compatibility'

      end
    end
  end
end
