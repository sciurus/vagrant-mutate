require 'vagrant-mutate/box_loader'
require 'vagrant-mutate/converter/converter'

module VagrantMutate

  class Mutate < Vagrant.plugin(2, :command)

    def execute
      opts = OptionParser.new do |o|
        o.banner = 'Usage: vagrant mutate <box-name-or-file> <provider>'
      end
      argv = parse_options(opts)
      return if !argv

      unless argv.length == 2
        @env.ui.info(opts.help)
        return
      end

      box_arg = argv[0]
      output_provider_arg = argv[1]

      input_loader  = BoxLoader.new(@env)
      input_box = input_loader.load(box_arg)

      output_loader = BoxLoader.new(@env)
      output_box = output_loader.prepare_for_output( input_box.name, output_provider_arg)

      converter  = Converter::Converter.create(@env, input_box, output_box)
      converter.convert

      input_loader.cleanup

      @env.ui.info "The box #{output_box.name} (#{output_box.provider_name}) is now ready to use."

    end

  end

end
