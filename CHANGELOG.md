# 0.2.6 (2014-05-04)
* Include CentOS 6.5/RHEL 6.5-friendly Qemu paths (#50)

# 0.2.5 (2014-02-01)
* Fix pci id for drives in kvm (#39)

# 0.2.4 (2014-01-23)
* Generate new vagrantfiles instead of copying them
* Set disk bus when converting to vagrant-libvirt (#41)

# 0.2.3 (2014-01-20)
* Warn when qemu version cannot read vmdk3 files (#29)
* Fix errors in how box name and provider were parsed (#35)
* Load box from file based on existence not name (#36)
* Warn when image is not the expected type for the provider (#38)

# 0.2.2 (2014-01-05)
* Determine virtualbox disk filename from ovf (#30)
* Move Qemu checks to own class

# 0.2.1 (2014-01-02)
* Support kvm as input (#17)

# 0.2.0 (2014-01-02)
* Fix how box is loaded by name (#19)
* Quit if input and output provider are the same (#27)
* Support libvirt as input (#18)

# 0.1.5 (2013-12-17)
* Preserve dsik interface type when coverting to KVM (#21)
* Remove dependency in minitar (#24)
* Support downloading input box (#9)
* Handle errors when reading ovf file

# 0.1.4 (2013-12-08)
* Rework box and converter implementation (#7)
* Write disk images as sparse files (#13)
* Switch vagrant-kvm disk format from raw to qcow2 (#16)
* Prefer the binary named qemu-system-* over qemu-kvm or kvm (#20)

# 0.1.3 (2013-12-03)

* Add support for vagrant-kvm (#12)
* Add acceptance tests

# 0.1.2 (2013-11-20)

* Rework provider and converter implementation (#7)

# 0.1.1 (2013-11-12)

* Fix handling of fractional virtual disk sizes (#11)

# 0.1.0 (2013-11-02)

* Initial release
