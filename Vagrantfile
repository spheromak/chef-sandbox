# -*- mode: ruby -*-
# vi: set ft=ruby :

#require 'berkshelf/vagrant'

Vagrant::Config.run do |config|
  # centos 6.3
  config.vm.box = "opscode-ubuntu-12.04"
  config.vm.box_url =  "https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04.box"
  #config.berkshelf.config_path = "~/sandbox/chef/knife.rb"

  config.vm.define :server do |server|
    hostname = "server"
    server.vm.boot_mode =  :headless
    server.vm.network  :hostonly, "192.168.1.10"
    #server.vm.network :bridged
    server.vm.forward_port 4000, 4040
    server.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "chef/cookbooks"
      chef.data_bags_path = "chef/data_bags"
      chef.roles_path =  "chef/roles"
      chef.add_recipe "users::bash"
      chef.add_recipe "chef-server::ktc-install"
      chef.add_recipe "post-vagrant::server"
    end
  end

  config.vm.define :client1 do |client|
    hostname = "client1"
    client.vm.boot_mode = :gui
    client.vm.network :hostonly, "192.168.1.11"
    client.vm.network :bridged
    client.vm.provision :chef_client do |chef|
      chef.chef_server_url = "http://192.168.1.10:4000"
      chef.validation_key_path = "chef/validation.pem"
    end
  end
 
  #
  # config.vm.provision :chef_solo do |chef|
  #   chef.cookbooks_path = "../my-recipes/cookbooks"
  #   chef.roles_path = "../my-recipes/roles"
  #   chef.data_bags_path = "../my-recipes/data_bags"
  #   chef.add_recipe "mysql"
  #   chef.add_role "web"
  #
  #   # You may also specify custom JSON attributes:
  #   chef.json = { :mysql_password => "foo" }
  # end

  #
  # config.vm.provision :chef_client do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
  #   chef.validation_key_path = "ORGNAME-validator.pem"
  # end
  #
  #
  #   chef.validation_client_name = "ORGNAME-validator"
end

