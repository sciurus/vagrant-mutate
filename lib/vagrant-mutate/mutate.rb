module VagrantMutate

  class mutate < Vagrant.plugin(2, :command)

    def execute
      opts = OptionParser.new do |o|
        o.banner = 'Usage: vagrant mutate box-name-or-file output-provider'
      end
      argv = parse_options(opts)
      return if !argv

      @env.ui.info( 'Hello from vagrant mutate!' )
    end

  end

end
