# -*- mode: ruby -*-
# vi: set ft=ruby :
#
require 'berkshelf/vagrant'
require 'json'


Vagrant::Config.run do |config|
  Sandbox::Config.parse

  config.vm.define :server do |server|
    server.vm.box = Sandbox::Config.vm("server")["box"]
    server.vm.box_url = Sandbox::Config.vm("server")["box_url"] if Sandbox::Config.vm("server").has_key? "box_url"
    server.vm.host_name = "server.vm"
    server.vm.boot_mode =  :headless
    server.vm.network  :hostonly, "192.168.1.10"
    server.vm.forward_port 4000, 4000 
    server.vm.provision :chef_solo do |chef|
      chef.data_bags_path = "chef/data_bags"
      chef.roles_path =  "chef/roles"
      chef.run_list = Sandbox::Config.run_list("server")
    end
  end

  ip=11
  Sandbox::Config.machines.each do |vm|
    next if vm == "server"
    config.vm.define vm.to_sym do |server|
      server.vm.box = Sandbox::Config.vm(vm)["box"]
      server.vm.box_url = Sandbox::Config.vm(vm)["box_url"] if Sandbox::Config.vm(vm).has_key? "box_url"
      server.vm.host_name = "#{vm}.vm"
      server.vm.boot_mode =  :headless
      server.vm.network  :hostonly, "192.168.1.#{ip}"
      server.berkshelf.node_name  = "vagrant"
      server.berkshelf.client_key = "chef/vagrant.pem" 
      server.vm.provision :chef_client do |chef|
        chef.add_recipe "vagrant-post::client"
        chef.chef_server_url = "http://192.168.1.10:4000"
        chef.validation_key_path = "chef/validation.pem"
        chef.json = { :chef_server => "http://192.168.1.10:4000" }
        chef.run_list = Sandbox::Config.run_list(vm)
      end
      ip += 1
    end
  end
end

module Vagrant
  module Provisioners

    class Base
      require 'chef'
      require 'chef/config'
      require 'chef/knife'
    end

    class ChefSolo 
      def cleanup
        node =  env[:vm].config.vm.host_name
        if node == "server.vm"
          puts "Cleaning up Validator key"
          File.unlink "chef/validation.pem" if File.exists? "chef/validation.pem"
          puts "Cleaning up Knife key" 
          File.unlink "chef/vagrant.pem" if File.exists? "chef/vagrant.pem" 
          return
        end
      end
    end

    class ChefClient
      ::Chef::Config.from_file(File.join( File.dirname(__FILE__), 'chef', 'knife.rb'))

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
            puts "Server reported: #{e.message}\nYou will have to clean the client/node by hand"
          end
        rescue Exception => e
          puts "Caught error while cleaning node from server:\n #{e.message}\nYou will have to clean the client/node by hand"
        end
      end     
    end
  end
end

class Sandbox
  class Config 
    class << self
    def parse
      # read in ext data
      unless File.exists?(defaults_file)
        default_run_list = %w/ recipe[bash::rcfiles] recipe[vim] recipe[tmux] recipe[apt] /
        json_data = {
              :vms => {
                "server" =>  { :box => "opscode-ubuntu-12.04",
                               :run_list => "server",
                               :attribs => {},
                               :server => true
                              },
                "client1" => { :box => "opscode-ubuntu-12.04",
                               :run_list => "client",
                               :attribs => {} }
              },
              :bags => {},
              :environments => {},
              :roles => {},
              :run_lists => { 
                "client" => %w/recipe[bash::rcfiles] recipe[vim] recipe[tmux] recipe[apt] recipe[vagrant-post::client]/,
                "server" => %w/recipe[bash::rcfiles] recipe[vim] recipe[tmux] recipe[apt] recipe[chef-server::rubygems-install]', 'recipe[vagrant-post::server]/
              },
              :boxes => {
                "opscode-ubuntu-12.04" =>  "https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04.box",
                "opscode-centos-6.3" => "https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-centos-6.3.box"
              
              }
            }

        puts "creating a standard defaults file in #{defaults_file}"
          File.open(defaults_file,"w") do |f|
            f.write(JSON.pretty_generate(json_data))
          end
      end

      @@defaults = JSON.parse(File.read(defaults_file))
    end
 
    def defaults_file 
      @@defaults_file ||=  File.expand_path File.dirname(__FILE__)  + "/.sandbox.json"
    end

    def defaults
      @@defaults 
    end

    def vm(box)
      if defaults["vms"].has_key? box
        return defaults["vms"][box]
      end
      return false
    end

    def run_list(box)
      if vm(box)['run_list'].is_a? String
        list= vm(box)['run_list']
        if defaults['run_lists'].has_key? list
          return defaults['run_lists'][list]
        end
      end
      raise ArgumentError, "You asked to use run_list '#{list}' but its not in config "
    end

    def machines
      defaults['vms'].keys
    end

  end
end
end

