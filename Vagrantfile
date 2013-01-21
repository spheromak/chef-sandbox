# -*- mode: ruby -*-
# vi: set ft=ruby :
#
require 'berkshelf/vagrant'
require 'json'


Vagrant::Config.run do |config|
  Sandbox.config

  network = Sandbox.network
  config.ssh.timeout = 100
  config.ssh.forward_agent = true
  config.vm.auto_port_range = (6200..6600)
  config.vm.boot_mode = :headless
  config.vm.customize [ "modifyvm", :id, "--natdnshostresolver1", "on" ]
  config.vm.define :server do |server|
    Sandbox.box "server"
    server.vm.box = Sandbox.vagrant_box
    server.vm.box_url = Sandbox.url
    server.vm.host_name = "server.vm"
    server.vm.network  :hostonly, "#{network}.10"
    server.vm.forward_port 4000, 4000 
    server.vm.provision :chef_solo do |chef|
      chef.data_bags_path = "chef/data_bags"
      chef.roles_path =  "chef/roles"
      chef.run_list = Sandbox.run_list
    end
  end

  ip=11
  Sandbox.machines.each do |vm|
    next if vm == "server"
    config.vm.define vm.to_sym do |server|
      Sandbox.box vm
      server.vm.box = Sandbox.vagrant_box
      server.vm.box_url = Sandbox.url 
      server.vm.host_name = "#{vm}.vm"
      server.vm.network  :hostonly, "#{network}.#{ip}"
      server.vm.provision :chef_client do |chef|
        chef.add_recipe "vagrant-post::client"
        chef.chef_server_url = "http://#{network}.10:4000"
        chef.validation_key_path = "chef/validation.pem"
        chef.json = { :chef_server => "http://#{network}.10:4000" }
        chef.run_list = Sandbox.run_list
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
  def self.box(value=nil)
    @box = value if value 
    @box
  end

  def self.config
    # read in ext data
    unless File.exists?(defaults_file)
      box "server"

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
              "server" => %w/recipe[bash::rcfiles] recipe[vim] recipe[tmux] recipe[apt] recipe[chef-server::rubygems-install] recipe[vagrant-post::server]/
            },
            :boxes => {
              "opscode-ubuntu-12.04" =>  "https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-ubuntu-12.04.box",
              "opscode-centos-6.3" => "https://opscode-vm.s3.amazonaws.com/vagrant/boxes/opscode-centos-6.3.box"
            },
            :network => "172.30.9"
          }

      puts "creating a standard defaults file in #{defaults_file}"
        File.open(defaults_file,"w") do |f|
          f.write(JSON.pretty_generate(json_data))
        end
    end

    defaults JSON.parse(File.read(defaults_file))
  end
 
  def self.defaults_file 
    @defaults_file ||=  File.expand_path File.dirname(__FILE__)  + "/.sandbox.json"
  end

  def self.defaults(value=nil)
    @defaults = value if value
    @defaults 
  end

  # return this box's url
  def self.url
    if defaults["vms"].has_key? box
      if defaults["vms"][box].has_key? "box"
        vbox = defaults["vms"][box]["box"]
        return defaults["boxes"][vbox] 
      end
    end
  end

  def self.network
    defaults["network"]
  end

  #
  # pulls the vagrant_box for the current box
  def self.vagrant_box
    if defaults["vms"].has_key? box
      if defaults["vms"][box].has_key? "box"
        return defaults["vms"][box]["box"]
      end
    end
  end

  def self.vm
    if defaults["vms"].has_key? box
      return defaults["vms"][box]
    end
    raise ArgumentError, "No box found named #{box}"
  end

  def self.run_list
    if vm['run_list'].is_a? String
      list= vm['run_list']
      if defaults['run_lists'].has_key? list
        return defaults['run_lists'][list]
      end
      raise ArgumentError, "You asked to use run_list '#{list}' but its not in config "
    else
      return vm['run_list']
    end
  end

  def self.machines
    defaults['vms'].keys
  end

end

