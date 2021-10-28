# Web development box packer

This is a Funtoo Linux that is packaged into a Vagrant box file.
Currently only a VirtualBox version is provided.
It is based on the [Funtoo Base Vagrant box](https://github.com/foobarlab/funtoo-base-packer)
and provides an environment for web development.

## Operating system

 - Funtoo Linux 1.4
 - Optional: experimental Funtoo next installation (work-in-progress)
 - Architecture: x86-64bit, intel64-nehalem (compatible with most CPUs since 2008)
   respectively generic_64 (Funtoo next)
 - Initial 30 GB dynamic sized HDD image (ext4), can be expanded
 - Timezone: UTC
 - NAT, host-only and bridged networking (virtio) by default
 - Vagrant user *vagrant* with password *vagrant* (can get superuser via sudo without password),
   additionally using the default SSH authorized keys provided by Vagrant
   (see https://github.com/hashicorp/vagrant/tree/master/keys) 
 - Optional: build your own Debian Kernel 5.10 (debian-sources)

## Applications and services

 - Ansible for provisioning the virtual machine
 - PHP, Python, Java, Ruby, Erlang, Elixir, Perl, Java, JavaScript, Haskell, Rust and
   C/C++ programming languages
 - Various SQL (MariaDB, PostgreSQL) and NoSQL databases (CouchDB)
 - RabbitMQ message queue
 - Lucene search index provided by Solr
 - Webserver (Apache, Nginx, Lighttpd)
 - Caching and reverse proxy (Varnish Cache, Nginx)
 - SSL certificate management (mkcert) with Root CA
 - dnsmasq (providing *.test* domain) for isolation and virtual hosts
 - Email catchall and Webmail interface

## Download pre-build images

Get the latest build from Vagrant Cloud:
[foobarlab/webdev](https://app.vagrantup.com/foobarlab/webdev)

## Build your own using Packer

Install [VirtualBox](https://www.virtualbox.org) (extensions not needed),
[Vagrant](https://www.vagrantup.com/) and [Packer](https://www.packer.io/).

The provided scripts make use of various commandline utils:

 - bash
 - wget
 - curl
 - jq
 - nproc
 - b2sum
 - git
 - make
 - sed
 - awk
 - grep

Type ```make``` for help, build your own box with ```make all```.

## Feedback and bug reports welcome

Please create an issue or submit a pull request.
