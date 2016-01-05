#!/usr/bin/env ruby
# Description: <Method description here>
#
# Description: hot add disk of currently selected instance
#ykim@redhat.com
#date: 2015.12.31
#changelog
#- discover existing attached volume devices names.
#- create volume and attach it to instance.

@method = 'hotadd_disk_openstack'

$evm.log("info", "#{@method} - EVM Automate Method Started")

require 'rest-client'
require 'json'
require 'fog'

vm = $evm.root['vm']
#tenantName = $evm.inputs['tenantName']
tenantName = $evm.root['dialog_tenantName']
vSize = $evm.root['dialog_size']
ext_mgt_system=vm.ext_management_system

# get the MAC address directly from OSP
# make sure to adjust the openstack_tenant or make it dynamic
credentials={
  :provider => "OpenStack",
  :openstack_api_key => ext_mgt_system.authentication_password,
  :openstack_username => ext_mgt_system.authentication_userid,
  :openstack_auth_url => "http://#{ext_mgt_system[:hostname]}:#{ext_mgt_system[:port]}/v2.0/tokens",
  :openstack_tenant => tenantName
  }

$evm.log("info", "#{@method} - Logging into to http://#{ext_mgt_system[:hostname]}:#{ext_mgt_system[:port]}/v2.0/tokens as #{ext_mgt_system.authentication_userid}")
compute = Fog::Compute.new(credentials)
volume = Fog::Volume.new(credentials)

v = volume.volumes.create(size: "#{vSize}" , display_name: "cfme_volume")
v.wait_for { status == 'available' }
server = compute.servers.get(vm.ems_ref)

### find device name
vol_list = []
alpha_list = ('a'..'z')
dev_alpha_count  = ''
server.volume_attachments.each { |id| vol_list << id['device'] }
('a'..'z').each_with_index { |i,j| dev_alpha_count = i if (j-1) == vol_list.count } 
device_name = "/dev/xvd" + dev_alpha_count

### attach volume
server.attach_volume(v.id, "#{device_name}")

$evm.log("info", "#{@method} - Created cinder and attched to #{server.name} with ID #{v.id}")

vm.custom_set("volume list","#{device_name}")
exit MIQ_OK
