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

Pull cookbooks used for chef-solo

      berks install --path chef/cookboks

Start your server

      vagrant up server

Upload cookbooks to your server

      berks upload

Start your client

      vagrant up client1

Next Steps
----
  I would like for this all to be jsut a vagrant up, right now berkshelf
has some vagrant integration going on, and I intend to make this more transparent
I started this project cause I wanted to be able to test multi-vm setups in 
jenkins, and as time permits I will continue to push updates.
