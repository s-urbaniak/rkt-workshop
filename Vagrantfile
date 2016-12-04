Vagrant.configure("2") do |config|
  config.vm.box = "fedora/25-cloud-base"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "2048"
    vb.cpus = "2"
  end

  config.vm.network "private_network", type: "dhcp"
  config.vm.provision :shell, :privileged => true, :path => "install-rkt.sh"
#  config.vm.synced_folder "./src", "/home/vagrant/src"
end
