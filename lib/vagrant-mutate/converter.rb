require 'zlib'
require 'archive/tar/minitar'

module VagrantMutate

  class Converter

    include Archive::Tar

    # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
    def initialize
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each do |ext|
          exe = File.join(path, "qemu-img#{ext}")
          return if File.executable? exe
        end
      end
      # if we make it here qemu-img command was not found
      raise Errors::QemuNotFound
    end

    def unpack_box(box_file)
      unless File.exists? box_file
        raise Errors::BoxFileNotFound, :box => box_file
      end

      # box may or may not be gzipped
      begin
        tar = Zlib::GzipReader.new(File.open(box_file, 'rb'))
      rescue
        tar = box_file
      end

      begin
        dir = Dir.mktmpdir
        Minitar.unpack(tar, dir)
      rescue => e
        raise Errors::ExtractBoxFailed, :error_message => e.message
      end

      return dir
    end

  end
end
