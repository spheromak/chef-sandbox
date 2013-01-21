# -*- mode: ruby -*-
# vi: set ft=ruby :
#
#

site :opscode

cookbook 'chef-server', github: 'opscode-cookbooks/chef-server', branch: '1.1.0'
cookbook 'ohai', github: 'opscode-cookbooks/ohai'
cookbook 'apt', github: 'opscode-cookbooks/apt'
cookbook 'erlang', github: 'opscode-cookbooks/erlang'
cookbook 'vim'
cookbook 'git'
cookbook 'tmux'
cookbook 'build-essential'
cookbook 'gecode'
cookbook 'couchdb', github: "opscode-cookbooks/couchdb"
cookbook 'zlib'
cookbook 'xml'
cookbook "chef-solo-search", git: 'git://github.com/edelight/chef-solo-search.git'
cookbook "bash", git: 'git://github.com/spheromak/bash-coookbook.git'
cookbook "vagrant-post", git: 'git://github.com/spheromak/vagrant-post-cookbook.git'
cookbook "omnibus_updater", github: "hw-cookbooks/omnibus_updater", branch: 'v0.0.4'

group "dev" do
  cookbook "minitest-handler"
  cookbook "chef_handler", git: 'git://github.com/opscode-cookbooks/chef_handler.git'
  cookbook "yum", git: 'git://github.com/opscode-cookbooks/yum.git'
end


