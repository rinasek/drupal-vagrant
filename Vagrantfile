# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

configValues = YAML.load_file("./config.yml")
data = configValues['vagrant-local']


$project_name = data['project']['name']
$project_location = data['project']['location']
$network_ip = data['vm']['network']['private_network']
$forward_host = data['vm']['network']['forwarded_port']['host']
$forward_guest = data['vm']['network']['forwarded_port']['host']
#$bridge_type = data['vm']['network']['bridge_type']




# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Every Vagrant virtual environment requires a box to build off of.

  config.vm.box = "puppetlabs-precise64"
  config.vm.box_url = "http://puppet-vagrant-boxes.puppetlabs.com/ubuntu-server-12042-x64-vbox4210-nocm.box"

  # VM's host name, will be picked up by hostmanager plugin, if available
  config.vm.hostname = "development." + $project_name

  # config.vm.network :public_network,  bridge: $bridge_type,  ip: $network_ip

  config.vm.network :private_network, ip: $network_ip
  config.vm.network :forwarded_port, guest: $forward_guest, host: $forward_host

  # Hostmanager plugin (vagrant-hostmanager)
  # Automatically adds entries to hosts file for host and guest systems
  if defined? VagrantPlugins::HostManager
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
  end
  
  # Mount folders
  config.vm.synced_folder "./", "/vagrant", id: "vagrant-root"
  config.vm.synced_folder $project_location, "/var/www"

# Enable shell provisioning to bootstrap puppet
  config.vm.provision :shell, :path => "bootstrap.sh"


  config.vm.provision :shell do |shell|
  shell.inline = "mkdir -p /etc/puppet/modules;
                  puppet module install ripienaar-concat"
end

  # Enable provisioning with Puppet stand alone, define where modules and manifests are
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path = "puppet/modules"
    puppet.options = ['--verbose']
  end


end
