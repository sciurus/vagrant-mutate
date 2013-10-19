module VagrantMutate

  class Converter

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

  end
end
