require 'vagrant-mutate/converter'

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
      output_provider = argv[1]

      unless SUPPORTED_OUTPUT_PROVIDERS.include? output_provider
        raise Errors::ProviderNotSupported, :provider => output_provider
      end

      c = Converter.new(@env)
      input_box = Box.new(@env)

      if box_arg =~ /\.box$/
        input_box.load_from_file(box_arg)
      else
        input_box.load_by_name(box_arg)
      end

      input_provider = input_box.provider
      unless SUPPORTED_INPUT_PROVIDERS.include? input_provider
        raise Errors::ProviderNotSupported, :provider => input_provider
      end

      output_box = Box.new(@env)
      output_box.prepare_for_output( input_box.name, output_provider)

      c.convert(input_box, output_box)

      input_box.cleanup

    end

  end

end
