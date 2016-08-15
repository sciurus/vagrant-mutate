module VagrantMutate
  class Qemu
    def self.verify_qemu_installed
      qemu_img_bin = nil
      logger = Log4r::Logger.new('vagrant::mutate')
      qemu_img_bin = VagrantMutate.find_bin("qemu-img")
      unless qemu_img_bin
        fail Errors::QemuImgNotFound
      end
      logger.info 'Found qemu-img: ' + qemu_img_bin
      qemu_img_bin
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
