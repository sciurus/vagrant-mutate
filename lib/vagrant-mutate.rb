require "vagrant-mutate/version"

module VagrantMutate

  class Plugin < Vagrant.plugin('2')
    name 'VagrantMutate'

    command 'mutate' do
      require 'vagrant-mutate/mutate'
      Mutate
    end

  end

end
