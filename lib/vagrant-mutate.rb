require 'vagrant-mutate/version'
require 'vagrant-mutate/errors'

module VagrantMutate
  def self.source_root
    @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
  end

  # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
  def self.find_bin(bin)
    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, "#{bin}#{ext}")
        if File.executable? exe
          return exe if File.executable?(exe) && !File.directory?(exe)
        end
      end
    end
    return nil
  end

  class Plugin < Vagrant.plugin('2')
    name 'vagrant-mutate'

    command 'mutate' do
      setup_i18n
      require 'vagrant-mutate/mutate'
      Mutate
    end

    def self.setup_i18n
      I18n.load_path << File.expand_path('locales/en.yml', VagrantMutate.source_root)
      I18n.reload!
    end
  end
end
