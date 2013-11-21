require 'vagrant-mutate/box'
require 'vagrant-mutate/converter'
require 'vagrant-mutate/provider/provider'

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

      c = Converter.new(@env)
      input_box = Box.new(@env)
      output_box = Box.new(@env)

      if box_arg =~ /\.box$/
        input_box.load_from_file(box_arg)
      else
        input_box.load_by_name(box_arg)
      end

      output_box.prepare_for_output( input_box.name, output_provider_arg)

      c.convert(input_box, output_box)

      input_box.cleanup

      @env.ui.info "The box #{output_box.name} (#{output_box.provider.name}) is now ready to use."

    end

  end

end
