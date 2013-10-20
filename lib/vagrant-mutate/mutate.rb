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

      if box_arg =~ /\.box$/
        box_name = box_arg[0..-5]
        input_box_dir = c.unpack_box(box_arg)
        cleanup_input = true
      else
        box_name = box_arg
        cleanup_input = false
        @env.ui.info ('Mutating box by name is not implemented yet')
        return
      end

      input_provider = c.determine_provider(input_box_dir)
      unless SUPPORTED_INPUT_PROVIDERS.include? input_provider
        raise Errors::ProviderNotSupported, :provider => input_provider
      end

      c.convert(input_box_dir, input_provider, output_provider, box_name)

      if cleanup_input == true
        c.cleanup(input_box_dir)
      end

    end

  end

end
