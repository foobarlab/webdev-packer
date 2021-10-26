# Web development Vagrant box

This is a Funtoo Linux that is packaged into a Vagrant box file.
Currently only a VirtualBox version is provided.
It is based on the [Funtoo Base Vagrant box](https://github.com/foobarlab/funtoo-base-packer)
and provides an environment for web development.

### What's included?

## Operating system

 - Funtoo Linux 1.4 from [base box](https://github.com/foobarlab/funtoo-base-packer)
 - Architecture: x86-64bit, intel64-nehalem (compatible with most CPUs since 2008)
 - Initial 30 GB dynamic sized HDD image (ext4), can be expanded
 - Timezone: ```UTC```
 - NAT, host-only and bridged networking (virtio)
 - Vagrant user *vagrant* with password *vagrant* (can get superuser via sudo without password),
   additionally using the default SSH authorized keys provided by Vagrant (see https://github.com/hashicorp/vagrant/tree/master/keys) 
 - Optional: build your own Debian Kernel 5.10 (debian-sources)

## Automation

 - Ansible for provisioning the virtual machine

## Developer stacks

 - PHP, Python, Java, Ruby, Erlang, Elixir, Perl, Java, Haskell, Rust, C/C++ programming languages
 - Various SQL and NoSQL databases, Messaging with RabbitMQ
 - Lucene search index provided by Solr
 - Caching and reverse proxy (Varnish Cache, Nginx)
 - SSL Certificate management
 - DNS handling (providing **.test** domain)

### Download pre-build images

Get the latest build from Vagrant Cloud: [foobarlab/webdev](https://app.vagrantup.com/foobarlab/webdev)

### Build your own using Packer

#### Preparation

 - Install [Vagrant](https://www.vagrantup.com/) and [Packer](https://www.packer.io/)

#### Build a fresh box

Type ```make``` for help, build your own box with ```make all```.

## Feedback and bug reports welcome

Please create an issue or submit a pull request.
