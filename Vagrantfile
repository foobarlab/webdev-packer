# -*- mode: ruby -*-
# vim: ts=2 sw=2 et ft=ruby :

system("./config.sh >/dev/null")

Vagrant.require_version ">= 2.1.0"

$script_export_packages = <<SCRIPT
# sync any guest packages to host (vboxsf)
rsync -avzh --delete /var/cache/portage/packages/* /vagrant/packages/
# clean guest packages
rm -rf /var/cache/portage/packages/*
# let it settle
sync && sleep 30
SCRIPT

$script_clean_kernel = <<SCRIPT
# clean stale kernel files
mount /boot || true
eclean-kernel -l
eclean-kernel -n 1
ego boot update
# clean kernel sources
cd /usr/src/linux
make distclean
# copy latest kernel config
cp -f /usr/src/kernel.config /usr/src/linux/.config
# prepare for module compiles
make olddefconfig
make modules_prepare
SCRIPT

$script_remove_kernel = <<SCRIPT
emerge --unmerge debian-sources
# clean stale kernel files
mount /boot || true
eclean-kernel -l
eclean-kernel -n 1
ego boot update
SCRIPT

$script_cleanup = <<SCRIPT
# debug: list running services
rc-status
# stop services
/etc/init.d/mysql stop || true
/etc/init.d/xdm stop || true
/etc/init.d/xdm-setup stop || true
/etc/init.d/elogind stop || true
/etc/init.d/gpm stop || true
/etc/init.d/rsyslog stop || true
/etc/init.d/dbus -D stop || true
/etc/init.d/haveged stop || true
/etc/init.d/udev stop || true
/etc/init.d/vixie-cron stop || true
/etc/init.d/dhcpcd stop || true
/etc/init.d/local stop || true
/etc/init.d/acpid stop || true
# let it settle
sync && sleep 15
# run cleanup script (from funtoo-base box)
/usr/local/sbin/foo-cleanup
# delete some logfiles
logfiles=( emerge emerge-fetch genkernel )
for i in "${logfiles[@]}"; do
    rm -f /var/log/$i.log
done
rm -f /var/log/portage/elog/*.log
# let it settle
sync && sleep 15
# debug: list running services
rc-status
# clean shell history
set +o history
rm -f /home/vagrant/.bash_history
rm -f /root/.bash_history
sync && sleep 5
# zerofree /boot
mount -v -n -o remount,ro /dev/sda1
zerofree /dev/sda1 && echo "zerofree: success on /dev/sda1 (boot)"
# zerofree root fs
mount -v -n -o remount,ro /dev/sda4
zerofree /dev/sda4 && echo "zerofree: success on /dev/sda4 (root)"
# swap
swapoff -v /dev/sda3
bash -c 'dd if=/dev/zero of=/dev/sda3 2>/dev/null' || true
mkswap /dev/sda3
SCRIPT

Vagrant.configure("2") do |config|
  #config.vagrant.sensitive = ["MySecretPassword", ENV["MY_TOKEN"]] # TODO hide sensitive information
  config.vm.box_check_update = false
  config.vm.box = "#{ENV['BUILD_BOX_NAME']}"
  config.vm.box_version = "<9999"   # TODO version constraint (not building funtoo next)
  config.vm.hostname = "#{ENV['BUILD_BOX_NAME']}"
  config.vm.provider "virtualbox" do |vb|
    vb.gui = (ENV['BUILD_HEADLESS'] == "false")
    vb.memory = "#{ENV['BUILD_BOX_MEMORY']}"
    vb.cpus = "#{ENV['BUILD_BOX_CPUS']}"
    # customize VirtualBox settings, see also 'virtualbox.json'
    vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
    vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
    vb.customize ["modifyvm", :id, "--audio", "pulse"]
    vb.customize ["modifyvm", :id, "--audiocontroller", "hda"]
    vb.customize ["modifyvm", :id, "--audioin", "on"]
    vb.customize ["modifyvm", :id, "--audioout", "on"]
    vb.customize ["modifyvm", :id, "--usb", "on"]
    vb.customize ["modifyvm", :id, "--usbehci", "off"]
    vb.customize ["modifyvm", :id, "--usbxhci", "off"]
    vb.customize ["modifyvm", :id, "--rtcuseutc", "on"]
    vb.customize ["modifyvm", :id, "--chipset", "ich9"]
    vb.customize ["modifyvm", :id, "--vram", "64"]
    vb.customize ["modifyvm", :id, "--vrde", "off"]
    vb.customize ["modifyvm", :id, "--hpet", "on"]
    vb.customize ["modifyvm", :id, "--hwvirtex", "on"]
    vb.customize ["modifyvm", :id, "--vtxvpid", "on"]
    vb.customize ["modifyvm", :id, "--nested-hw-virt", "on"]
    vb.customize ["modifyvm", :id, "--largepages", "on"]
    vb.customize ["modifyvm", :id, "--spec-ctrl", "off"]
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
    vb.customize ["modifyvm", :id, "--accelerate3d", "on"]
    # spectre meltdown mitigations, see https://www.virtualbox.org/ticket/17987
    #vb.customize ["modifyvm", :id, "--largepages", "off"]
    #vb.customize ["modifyvm", :id, "--spec-ctrl", "on"]
    #vb.customize ["modifyvm", :id, "--ibpb-on-vm-entry", "on"]
    #vb.customize ["modifyvm", :id, "--ibpb-on-vm-exit", "on"]
    #vb.customize ["modifyvm", :id, "--l1d-flush-on-sched", "off"]
    #vb.customize ["modifyvm", :id, "--l1d-flush-on-vm-entry", "on"]
    #vb.customize ["modifyvm", :id, "--nestedpaging", "off"]
    # clipboard:
    vb.customize ["modifyvm", :id, "--clipboard-mode", "bidirectional"]
  end

  # force base mac address to be re-generated
  #config.vm.base_mac = nil

  # fixed mac address for eth0
  config.vm.base_mac = "080027344abc"

  # adapter 1 (eth0): private network (NAT with forwarding)
  config.vm.network "forwarded_port", guest: 8080, host: 8080   # apache
  config.vm.network "forwarded_port", guest: 8000, host: 8000   # lighttpd / dashboard
  config.vm.network "forwarded_port", guest: 3306, host: 3306   # mysql
  config.vm.network "forwarded_port", guest: 5432, host: 5432   # postgresql

  # adapter 2 (eth1): public network (bridged)
  config.vm.network "public_network",
    type: "dhcp",
    mac: "0800276c6237",  # fixed, pattern: 080027xxxxxx
    use_dhcp_assigned_default_route: true,
    bridge: [
      "eth0",
      "wlan0",
      "en0: Wi-Fi (Airport)",
      "en1: Wi-Fi (AirPort)"
    ]

  config.ssh.insert_key = false
  config.ssh.connect_timeout = 60

  config.vm.synced_folder '.', '/vagrant', disabled: false, automount: true

  # debug: show network interfaces + ip adresses
  config.vm.provision "net_debug", type: "shell", privileged: true, inline: <<-SHELL
    echo "Configured network interfaces:"
    ip a | grep glo | awk '{print $8 " => " $2}' | cut -f1 -d/
    ip a | grep link/ether | awk '{print "MAC  => " $2}'
    cat /etc/udev/rules.d/70-persistent-net.rules || true
  SHELL

  # ansible provisioning executed only in finalizing step (finalize.sh)
  config.vm.provision "provision_ansible", type: "ansible_local" do |ansible|
    ansible.install = false
    ansible.verbose = "v"
    ansible.compatibility_mode = "2.0"
    ansible.playbook = "ansible/provision.yml"
    ansible.config_file = "ansible/ansible.cfg"
    ansible.inventory_path = "ansible/environment/#{ENV['BUILD_ENVIRONMENT']}"
    ansible.raw_arguments  = ["--connection=local"]
    ansible.extra_vars = {
      mysql_root_password: "#{ENV['BUILD_MYSQL_ROOT_PASSWORD']}"
    }
  end

  config.vm.provision "export_packages", type: "shell", inline: $script_export_packages, privileged: true
  config.vm.provision "clean_kernel", type: "shell", inline: $script_clean_kernel, privileged: true
  config.vm.provision "remove_kernel", type: "shell", inline: $script_remove_kernel, privileged: true
  config.vm.provision "cleanup", type: "shell", inline: $script_cleanup, privileged: true
  # TODO add trigger for disk compaction?
end
