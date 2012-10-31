Chef Server Sandbox
----

This is a simple setup to get a single chef-server + 1 client up and running 
for doing work/testing locally. The server will nat port 4000 local to the 
server vm. The repo has a .chef/knife.rb setup to work relative to the repo.
The cookbooks that run on server will copy the validation and setup a knife 
client for usage from withing the repo against the server thats built. The 
client vm will use the validation pem to register against the server. All of it
should clean up when vagrant destroy is ran. 



Installing
----
Clone this repo

      git clone git://github.com/spheromak/chef-sandbox.git

Get in that repo

      cd chef-sandbox

Install The Required gems

      bundle install

Vagrant UP!

      vagrant up 

This should provision your server and a single client.


Next Steps
----
I started this project cause I wanted to be able to test multi-vm setups in 
jenkins, and as time permits I will continue to push updates.
