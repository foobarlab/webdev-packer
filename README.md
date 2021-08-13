# Web Development Vagrant box

This is a Funtoo Linux that is packaged into a Vagrant box file. Currently only a VirtualBox version is provided.
It is based on the [Funtoo Base Vagrant box](https://github.com/foobarlab/funtoo-base-packer) and provides an environment for web development.

### What's included?

 - Funtoo Linux 1.4
 - Architecture: x86-64bit, intel64-nehalem (compatible with most CPUs since 2008)
 - 50 GB dynamic sized HDD image (ext4), can be expanded
 - Timezone: ```UTC```
 - NAT Networking using DHCP (virtio)
 - Vagrant user *vagrant* with password *vagrant* (can get superuser via sudo without password), additionally using the default SSH authorized keys provided by Vagrant (see https://github.com/hashicorp/vagrant/tree/master/keys) 
 - Optional: build your own Debian Kernel 5.10 (debian-sources)
 - List of installed software:
    - Any software installed in the [base box](https://github.com/foobarlab/funtoo-base-packer)
    - TODO

### Download pre-build images

Get the latest experimental build from Vagrant Cloud: [foobarlab/webdev](https://app.vagrantup.com/foobarlab/webdev)

### Build your own using Packer

#### Preparation

 - Install [Vagrant](https://www.vagrantup.com/) and [Packer](https://www.packer.io/)

#### Build a fresh VirtualBox box

 - Run ```./build.sh```, followed by ```./finalize.sh```
 
#### Quick test the box file

 - Run ```./test.sh```

#### Test Ansible provisioning (for development only)

 - Run ```./test_ansible.sh```

#### Upload the box to Vagrant Cloud (account required)

 - Run ```./upload.sh```

### Regular use cases

#### Initialize a fresh box (initial state, any modifications are lost)

 - Run ```./init.sh```

#### Power on the box (keeping previous state)

 - Run ```./startup.sh```

### Special use cases

#### Show current build config

 - Run ```./config.sh```

#### Cleanup build environment (poweroff and remove any related Vagrant and VirtualBox machines)

 - Run ```./clean_env.sh```

#### Cleanup temporary build Vagrant box

 - Run ```./clean_box.sh```

#### Cleanup build environment

 - Run ```./clean.sh```

#### Generate Vagrant Cloud API Token

 - Run ```./vagrant_cloud_token.sh```

#### Keep only a maximum number of boxes in Vagrant Cloud (experimental)

 - Run ```./clean_cloud.sh```

## Feedback and bug reports welcome

Please create an issue or submit a pull request.
