require 'vagrant-mutate/box_loader'
require 'vagrant-mutate/qemu'
require 'vagrant-mutate/converter/converter'

module VagrantMutate
  class Mutate < Vagrant.plugin(2, :command)
    def execute
      options = {}
      options[:input_provider] = nil
      options[:version] = nil
      options[:force_virtio] = false
      options[:quiet] = false

      opts = OptionParser.new do |o|
        o.banner = 'Usage: vagrant mutate <box-name-or-file-or-url> <provider>'
        o.on('--input-provider PROVIDER',
             'Specify provider for input box') do |p|
          options[:input_provider] = p
        end
        o.on('--version VERSION',
             'Specify version for input box') do |p|
          options[:version] = p
        end
        o.on('--force-virtio',
             'Force virtio disk driver') do |p|
          options[:force_virtio] = true
        end
        o.on("--quiet", "Convert silently") do |v|
          options[:quiet] = true
        end
      end
      argv = parse_options(opts)
      return unless argv

      unless argv.length == 2
        @env.ui.info(opts.help)
        return
      end

      options[:box_arg] = argv[0]
      options[:output_provider] = argv[1]

      Qemu.verify_qemu_installed
      Qemu.verify_qemu_version(@env)

      input_loader  = BoxLoader.new(@env)
      input_box = input_loader.load(options[:box_arg], options[:input_provider], options[:version])

      output_loader = BoxLoader.new(@env)
      output_box = output_loader.prepare_for_output(input_box.name, options[:output_provider], input_box.version)

      converter  = Converter::Converter.create(@env, input_box, output_box, options[:force_virtio], options[:quiet])
      converter.convert

      input_loader.cleanup

      if options[:quiet] == false
        @env.ui.info "The box #{output_box.name} (#{output_box.provider_name}) is now ready to use."
      end
    end
  end
end
