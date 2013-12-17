# Vagrant-Mutate

Vagrant-mutate is a [vagrant](http://www.vagrantup.com/) plugin to convert vagrant boxes to work with different providers.

## Supported Conversions

* Virtualbox to [kvm](https://github.com/adrahon/vagrant-kvm) (tested against 0.1.4)
* Virtualbox to [libvirt](https://github.com/pradels/vagrant-libvirt) (tested against 0.0.11)

## Installation

### qemu-img

First, you must install [qemu-img](http://wiki.qemu.org/Main_Page). Support for the disk image format most commonly used in vagrant boxes for virtualbox was added in [version 1.2.0](http://wiki.qemu.org/ChangeLog/1.2#VMDK); if you have an older version vagrant-mutate will warn you and most likely won't work.

#### Debian and derivatives

    apt-get install qemu-utils

#### Red Hat and derivatives

    yum install qemu-img

#### OS X

QEMU is available from [homebrew](http://brew.sh/)

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

Or if you had already added the virtualbox version of the box to vagrant and now want to use it with libvirt

    vagrant mutate precise32 libvirt

To export a box you created with vagrant mutate, just repackage it, e.g.

    vagrant box repackage precise32 libvirt


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
