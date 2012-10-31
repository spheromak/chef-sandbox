# -*- mode: ruby -*-
# vi: set ft=ruby :
#
require 'berkshelf/vagrant'
Vagrant::Config.run do |config|

  # 
  # centos 6.3
  # config.vm.box = "opscode-centos-6.3"
  # config.vm.box_url "https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-centos-6.3.box"
  #
  #
  
  config.vm.box = "opscode-ubuntu-12.04"
  config.vm.box_url =  "https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04.box"


  config.vm.define :server do |server|
    server.vm.host_name = "server"
    server.vm.boot_mode =  :headless
    server.vm.network  :hostonly, "192.168.1.10"
    #server.vm.network :bridged
    server.vm.forward_port 4000, 4000 
    server.vm.provision :chef_solo do |chef|
      #chef.cookbooks_path = "chef/cookbooks"
      chef.data_bags_path = "chef/data_bags"
      chef.roles_path =  "chef/roles"
      %w{bash::rcfiles vim tmux chef-server::rubygems-install vagrant-post::server}.each do |recipe|
        chef.add_recipe recipe
      end
    end
  end

  config.vm.define :client1 do |client|
    client.vm.host_name = "client1"
    client.vm.boot_mode = :gui
    client.vm.network :hostonly, "192.168.1.11"
    client.vm.network :bridged

    client.vm.provision :chef_client do |chef|
      chef.add_recipe "vagrant-post::client"
      chef.chef_server_url = "http://192.168.1.10:4000"
      chef.validation_key_path = "chef/validation.pem"
      %w{bash::rcfiles vim tmux vagrant-post::client}.each do |recipe|
        chef.add_recipe recipe
      end
      chef.json = { :chef_server => "http://192.168.1.10:4000" }
    end
  end
 
end

module Vagrant
  module Provisioners
    class Base
      require 'chef'
      require 'chef/config'
      require 'chef/knife'
      
      ::Chef::Config.from_file(File.join( File.dirname(__FILE__), 'chef', 'knife.rb'))
    end

    class ChefSolo 
      def cleanup
        node =  env[:vm].config.vm.host_name
        puts "Clening up chef client/node: #{node}"
        if node == "server"
          puts "Cleaning up Validator key"
          File.unlink "chef/validation.pem"
          puts "Cleaning up Knife key"
          File.unlink "chef/vagrant.pem"
          return
        end
      end
    end

    class ChefClient
      def cleanup
        node =  env[:vm].config.vm.host_name
        puts "cleaning up #{node} on chef server"

        begin 
          ::Chef::REST.new(::Chef::Config[:chef_server_url]).delete_rest("clients/#{node}")
          ::Chef::REST.new(::Chef::Config[:chef_server_url]).delete_rest("nodes/#{node}")

        rescue Net::HTTPServerException => e
          if e.message == '404 "Not Found"'
            puts "Server says it doesn't exist continuing.."
          else 
            puts e.message
            puts e.backtrace
            exit 1
          end
        end

      end
    end
  end
end
