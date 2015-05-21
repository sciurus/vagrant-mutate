require 'vagrant-mutate/version'
require 'vagrant-mutate/errors'

module VagrantMutate
  def self.source_root
    @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
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
