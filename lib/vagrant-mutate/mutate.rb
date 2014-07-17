require 'vagrant-mutate/box_loader'
require 'vagrant-mutate/qemu'
require 'vagrant-mutate/converter/converter'

module VagrantMutate

  class Mutate < Vagrant.plugin(2, :command)

    def execute
      options = {}
      options[:input_provider] = nil

      opts = OptionParser.new do |o|
        o.banner = 'Usage: vagrant mutate <box-name-or-file-or-url> <provider>'
        o.on("--input_provider PROVIDER",
          "Specify provider for input box") do |p|
          options[:input_provider] = p
        end
      end

      argv = parse_options(opts)
      return if !argv

      unless argv.length == 2
        @env.ui.info(opts.help)
        return
      end

      options[:box_arg] = argv[0]
      options[:output_provider] = argv[1]

      Qemu.verify_qemu_installed
      Qemu.verify_qemu_version(@env)

      input_loader  = BoxLoader.new(@env)
      input_box = input_loader.load( options[:box_arg], options[:input_provider] )

      output_loader = BoxLoader.new(@env)
      output_box = output_loader.prepare_for_output( input_box.name, options[:output_provider])

      converter  = Converter::Converter.create(@env, input_box, output_box)
      converter.convert

      input_loader.cleanup

      @env.ui.info "The box #{output_box.name} (#{output_box.provider_name}) is now ready to use."

    end

  end

end
