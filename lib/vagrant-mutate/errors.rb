require 'vagrant'

module VagrantMutate
  module Errors
    class VagrantMutateError < Vagrant::Errors::VagrantError
      error_namespace('vagrant_mutate.errors')
    end

    class ProviderNotSupported < VagrantMutateError
      error_key(:provider_not_supported)
    end

    class QemuNotFound < VagrantMutateError
      error_key(:qemu_not_found)
    end

  end
end
