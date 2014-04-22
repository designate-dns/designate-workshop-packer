VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'designate-workshop'
  config.vm.box_url = 'file://designate-workshop_virtualbox.box'
  
  config.vm.provider "virtualbox" do |box|
  	box.customize ["modifyvm", :id, "--memory", "2048"]
  	box.customize ["modifyvm", :id, "--cpus",   "2"]
  	box.customize ["modifyvm", :id, "--hwvirtex", "on"]
  end
end
