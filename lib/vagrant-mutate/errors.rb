require 'vagrant'

module VagrantMutate
  module Errors
    class VagrantMutateError < Vagrant::Errors::VagrantError
      error_namespace('vagrant_mutate.errors')
    end

    class CloudNotSupported < VagrantMutateError
      error_key(:cloud_not_supported)
    end

    class ProvidersMatch < VagrantMutateError
      error_key(:providers_match)
    end

    class ProviderNotSupported < VagrantMutateError
      error_key(:provider_not_supported)
    end

    class QemuNotFound < VagrantMutateError
      error_key(:qemu_not_found)
    end

    class QemuImgNotFound < VagrantMutateError
      error_key(:qemu_img_not_found)
    end

    class BoxNotFound < VagrantMutateError
      error_key(:box_not_found)
    end

    class TooManyBoxesFound < VagrantMutateError
      error_key(:too_many_boxes_found)
    end

    class ExtractBoxFailed < VagrantMutateError
      error_key(:extract_box_failed)
    end

    class ParseIdentifierFailed < VagrantMutateError
      error_key(:parse_identifier_failed)
    end

    class DetermineProviderFailed < VagrantMutateError
      error_key(:determine_provider_failed)
    end

    class CreateBoxDirFailed < VagrantMutateError
      error_key(:create_box_dir_failed)
    end

    class WriteMetadataFailed < VagrantMutateError
      error_key(:write_metadata_failed)
    end

    class WriteVagrantfileFailed < VagrantMutateError
      error_key(:write_vagrantfile_failed)
    end

    class WriteDiskFailed < VagrantMutateError
      error_key(:write_disk_failed)
    end

    class ParseQemuVersionFailed < VagrantMutateError
      error_key(:parse_qemu_version_failed)
    end

    class QemuInfoFailed < VagrantMutateError
      error_key(:qemu_info_failed)
    end

    class BoxAttributeError < VagrantMutateError
      error_key(:box_attribute_error)
    end

    class URLError < VagrantMutateError
      error_key(:url_error)
    end

  end
end
