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
        @env.ui.info( opts.help )
        return
      end

      box_arg = argv[0]
      output_provider = argv[1]

      unless SUPPORTED_OUTPUT_PROVIDERS.include? output_provider
        raise Errors::ProviderNotSupported,
          :provider => output_provider
      end

      c = Converter.new

      if box_arg =~ /\.box$/
        input_box_dir = c.unpack_box(box_arg)
        @env.ui.info ( input_box_dir )
      else
        @env.ui.info ('Mutating box by name is not implemented yet')
      end

      @env.ui.info( 'Hello from vagrant mutate' )
    end

  end

end
