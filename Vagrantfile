# -*- mode: ruby -*-
# vi: set ft=ruby :
#
require 'berkshelf/vagrant'

Vagrant::Config.run do |config|
  # centos 6.3
  config.vm.box = "opscode-ubuntu-12.04"
  config.vm.box_url =  "https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04.box"

  config.vm.define :server do |server|
    server.vm.boot_mode =  :headless
    server.vm.network  :hostonly, "192.168.1.10"
    #server.vm.network :bridged
    server.vm.forward_port 4000, 4000 
    server.vm.provision :chef_solo do |chef|
      chef.cookbooks_path = "chef/cookbooks"
      chef.data_bags_path = "chef/data_bags"
      chef.roles_path =  "chef/roles"
      %w{bash::rcfiles vim tmux chef-server::rubygems-install post-vagrant::server}.each do |recipe|
        chef.add_recipe recipe
      end
    end
  end

  config.vm.define :client1 do |client|
    client.vm.boot_mode = :gui
    client.vm.network :hostonly, "192.168.1.11"
    client.vm.network :bridged

    client.vm.provision :chef_client do |chef|
      chef.add_recipe "post-vagrant::client"
      chef.chef_server_url = "http://192.168.1.10:4000"
      chef.validation_key_path = "chef/validation.pem"
      %w{bash::rcfiles vim tmux post-vagrant::client}.each do |recipe|
        chef.add_recipe recipe
      end
      chef.json = { :chef_server => "http://192.168.1.10:4000" }
    end
  end
 
end

#      def cleanup
#        if env[:vm].config.vm.host_name
#          puts `sh -c 'knife client delete #{env[:vm].config.vm.host_name} -y'`
#          puts `sh -c 'knife node delete #{env[:vm].config.vm.host_name} -y'`
#
#          # remove validator and vagrant keys
#          if env[:vm].config.vm.host_name == "server"
#            puts `sh -c 'rm chef/validation.pem'`
#            puts `sh -c 'rm chef/vagrant.pem'`
#          end
#        else
#          puts "No host_name was defined for the box... unable to remove it from chef"
#        end
#      end
#    end
#  end
#end
