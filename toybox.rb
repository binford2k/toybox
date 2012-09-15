#! /usr/bin/env ruby
require 'yaml'
require 'webrick'
require 'socket'
require 'open-uri'

# keyboard scancode processing
require 'keycodes.rb'

ARGV.each do|a|
  if ['-h', '--help'].include? a
    puts <<EOM
This is a simple VirtualBox image builder.

It will read in a config.yaml file with the following structure:
  $ cat config.yaml 
  --- 
  name:     "Puppet"
  ostype:   "RedHat_64"
  iso:      "CentOS-6.3-x86_64-minimal.iso"
  uri:      "http://mirror.cisp.com/CentOS/6.3/isos/x86_64/CentOS-6.3-x86_64-minimal.iso"
  memory:   "512"
  disksize: "8096"
  bootwait: "10"

Toybox will create a new VBox instance with the requested name and ostype and
will set the parameters of the instance to match memory and disksize (in MB).
If the iso path provided does not exist, then it will be downloaded from uri.
Toybox will then wait for bootwait seconds before passing in kickstart info.

If you provide the optional kickstart parameter, the instance can load an arbirtrary
kickstart file from whatever URI provided. Otherwise, Toybox will serve ks.cfg
from the current working directory.

Toybox will also serve up the VBoxGuestAdditions.iso for installation by the VM.
EOM
  exit 1  
  end
end

unless File.exist?('config.yaml')
    raise "config.yaml doesn't exist!"
end

config = YAML.load_file('config.yaml')
filename = config['name'].gsub(/\s+/, "")

# if the file doesn't exist, let's grab it.
if not File.exists?(config['iso'])
  File.open(config['iso'], 'wb') do |file|
    open(config['uri']) do |uri|
      file.write(uri.read)
    end
  end
end

# Build out the actual VM and get it booted.
system("VBoxManage createvm --name \"#{config['name']}\" --ostype #{config['ostype']} --register")
system("VBoxManage modifyvm \"#{config['name']}\" --memory #{config['memory']}")
system("VBoxManage createhd --filename #{filename}.vdi --size #{config['disksize']}")

system("VBoxManage storagectl \"#{config['name']}\" --name \"SATA Controller\" --add sata")
system("VBoxManage storageattach \"#{config['name']}\" --storagectl \"SATA Controller\" --port 0 --device 0 --type hdd --medium #{filename}.vdi")

system("VBoxManage storagectl \"#{config['name']}\" --name \"IDE Controller\" --add ide")
system("VBoxManage storageattach \"#{config['name']}\" --storagectl \"IDE Controller\" --port 0 --device 1 --type dvddrive --medium #{config['iso']}")

system("VBoxManage startvm \"#{config['name']}\"")

# spin up a kickstart server
kickstart_server = Thread.new do 
  server = WEBrick::HTTPServer.new(:Port => 8080)
  server.mount('/', WEBrick::HTTPServlet::FileHandler, './')
  [:INT, :TERM].each { |sig| trap(sig) { server.stop } }
  server.start
end

# wait for the box to boot
sleep(config['bootwait'].to_i)

# use ip for kickstart and for downloading VBoxGuestAdditions
ip = IPSocket.getaddress(Socket.gethostname)
if config.has_key?('kickstart')
  kickstart = config['kickstart']
else
  kickstart = "http://#{ip}:8080/ks.cfg"
end

# send text to the VM to set the kickstart boot option
keycodes([:tab, " selinux=0 ks=#{kickstart} hostip=#{ip}", :enter]) do |hex|
  system("VBoxManage controlvm \"#{config['name']}\" keyboardputscancode #{hex}")
end

# wait until the VM shuts down
while `VBoxManage showvminfo \"#{config['name']}\" --machinereadable`.scan(/VMState="(\w*)"/) == [['running']] do
  sleep(10)
end

# disconnect the DVD
sleep(5) # make sure that the box is actually off!
system("VBoxManage storageattach \"#{config['name']}\" --storagectl \"IDE Controller\" --port 0 --device 1 --type dvddrive --medium emptydrive")

kickstart_server.kill

puts "* You can now package this box with `vagrant package --base #{config['name']}`"
puts "  - Optionally, you can then remove the #{config['name']} instance using the VirtualBox manager."
puts "* You should then add it with `vagrant box add #{config['name']} package.box`"
puts "* At that point, edit your Vagrantfile with the name of the box and the"
puts "  names of the agents that you want connected to the network."
puts "* vagrant up and enjoy!"
