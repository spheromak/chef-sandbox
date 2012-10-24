cfg_dir = File.expand_path File.dirname(__FILE__)  

log_level                :info
log_location             STDOUT
node_name                'vagrant'
client_key               "#{cfg_dir}/vagrant.pem"
validation_client_name   'chef-validator'
validation_key           '/etc/chef/validation.pem'
chef_server_url          'http://localhost:4000'
cache_type               'BasicFile'
cache_options( :path => "#{cfg_dir}/checksums" )
cookbook_path [ "#{cfg_dir}/chef/cookbooks" ]
