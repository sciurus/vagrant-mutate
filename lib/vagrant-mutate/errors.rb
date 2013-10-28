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

    class BoxNotFound < VagrantMutateError
      error_key(:box_not_found)
    end

    class ExtractBoxFailed < VagrantMutateError
      error_key(:extract_box_failed)
    end

    class DetermineProviderFailed < VagrantMutateError
      error_key(:determine_provider_failed)
    end

    class CreateBoxDirFailed < VagrantMutateError
      error_key(:create_box_dir_failed)
    end

    class MetadataWriteError < VagrantMutateError
      error_key(:metadata_write_error)
    end

  end
end
