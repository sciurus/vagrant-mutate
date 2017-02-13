# Vagrant-Mutate

Vagrant-mutate is a vagrant plugin to convert vagrant boxes to work with different providers.

## Supported Conversions

* Virtualbox to kvm
* Virtualbox to libvirt
* Virtualbox to bhyve
* Libvirt to kvm
* Kvm to libvirt

## Compatibility

Vagrant-mutate 0.3 and later requires Vagrant 1.5. If you are using an older vagrant, install vagrant-mutate version 0.2.6.

## Installation

### qemu-img and libvirt development

First, you must install [qemu-img](http://wiki.qemu.org/Main_Page) and the libvirt development libraries. Information on supported versions is listed at [QEMU Version Compatibility](https://github.com/sciurus/vagrant-mutate/wiki/QEMU-Version-Compatibility).

#### Debian and derivatives

    apt-get install qemu-utils libvirt-dev ruby-dev

#### Red Hat and derivatives

    yum install qemu-img libvirt-devel rubygem-ruby-libvirt ruby-devel redhat-rpm-config

#### OS X

QEMU and libvirt are available from [homebrew](http://brew.sh/)

#### Windows

Download and install it from [Stefan Weil](http://qemu.weilnetz.de/) or compile it yourself.

### vagrant-mutate

Now you're ready to install vagrant-mutate. To install the latest released version simply run

    vagrant plugin install vagrant-mutate

To install from source, clone the repository and run `rake build`. That will produce a gem file in the _pkg_ directory which you can then install with `vagrant plugin install`.

## Usage

The basic usage is

    vagrant mutate box-name-or-file-or-url output-provider

For example, if you wanted to download a box created for virtualbox and add it to vagrant for libvirt

    vagrant mutate http://files.vagrantup.com/precise32.box libvirt

Or if you had already downloaded it

    vagrant mutate precise32.box libvirt

Or if you had already added the box to vagrant and now want to use it with libvirt

    vagrant mutate precise32 libvirt

The latter syntax works for boxes you added from Vagrant Cloud or Atlas too. If you have installed multiple versions of these boxes, vagrant-mutate will always use the latest one.

    $ vagrant box list
    hashicorp/precise64  (virtualbox, 1.1.0)
    $ vagrant mutate hashicorp/precise32 libvirt

If you have a box for multiple providers, you must specify the provider to use for input using the *--input-provider* option, e.g.

    $ vagrant box list
    precise32  (kvm)
    precise32  (virtualbox)
    $ vagrant mutate --input-provider=virtualbox precise32 libvirt

To export a box you created with vagrant mutate, just repackage it, e.g.

    vagrant box repackage precise32 libvirt

If you want to force the output box to use virtio for the disk interface, no matter what interface the input box used, use the *--force-virtio* option.


## Debugging

vagrant and vagrant-mutate will output lots of information as they run if you set the VAGRANT_LOG environment variable to INFO. See [here](http://docs-v1.vagrantup.com/v1/docs/debugging.html) for information on how to do that on your operating system.

If you experience any problems, please open an issue on [github](https://github.com/sciurus/vagrant-mutate/issues).

## Contributing

Contributions are welcome! I'd especially like to see support for converting between more providers added.

To contribute, follow the standard flow of

1. Fork it
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Make sure the acceptance tests pass (`ruby test/test.rb`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create new Pull Request

Even if you can't contribute code, if you have an idea for an improvement please open an [issue](https://github.com/sciurus/vagrant-mutate/issues).
