require 'vagrant-mutate/box_loader'
require 'vagrant-mutate/qemu'
require 'vagrant-mutate/converter/converter'

module VagrantMutate
  class Mutate < Vagrant.plugin(2, :command)
    def execute
      options = {}
      options[:input_provider] = nil
      options[:version] = nil

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
        # check for optional argument to force virtio disk driver in Vagrantfile (for libvirt)
        o.on('--force-virtio',
             'Force virtio disk driver in Vagrantfile for libvirt output provider') do |p|
          options[:force_virtio] = true
        end

      end

      argv = parse_options(opts)
      return unless argv

      unless argv.length >= 2
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

      # accept value of optional argument --force-virtio if it is set in the ARGV options
      if options[:force_virtio] == true
        # ignore --force-virtio if provider is not libvirt
        if options[:output_provider] == "libvirt"
          output_box = output_loader.prepare_for_output(input_box.name, options[:output_provider], input_box.version, options[:force_virtio])
        else
          @env.ui.info "Ignoring: --force-virtio for output provider #{options[:output_provider]}. Parameter is only available for libvirt output provider."
          output_box = output_loader.prepare_for_output(input_box.name, options[:output_provider], input_box.version, )
        end
      else
        output_box = output_loader.prepare_for_output(input_box.name, options[:output_provider], input_box.version, )
      end

      converter  = Converter::Converter.create(@env, input_box, output_box)
      converter.convert

      input_loader.cleanup

      @env.ui.info "The box #{output_box.name} (#{output_box.provider_name}) is now ready to use."
    end
  end
end
