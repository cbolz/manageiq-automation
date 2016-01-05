#!/usr/bin/env ruby
#
#
# Description: <Method description here>
#
# Description: Create snapshot of currently selected instance
#http://www.jung-christian.de/2015/12/create-snapshots-in-openstack/
#
=begin
changelog:
3. adding "tenant" button
2. adding snapshot prefix with date string
1. refer from: http://www.jung-christian.de/2015/12/create-snapshots-for-a-service-in-openstack/
 
=end

@method = 'create_snapshot'

$evm.log("info", "#{@method} - EVM Automate Method Started")

require 'rest-client'
require 'json'
require 'fog'

vm = $evm.root['vm']
#tenantName = $evm.inputs['tenantName']
tenantName = $evm.root['dialog_tenantName']
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
server = compute.servers.get(vm.ems_ref)
snapshot_prefix = Time.now.strftime('%Y-%m-%d_%H-%M-%S')

response = server.create_image "#{snapshot_prefix}-#{server.name}", :metadata => { :environment => 'development' }
snapshot_name = "#{snapshot_prefix}-#{server.name}"
image_id = response.body["image"]["id"]

$evm.log("info", "#{@method} - Created Snapshot named #{snapshot_name} with ID #{image_id}")

vm.custom_set("Snapshot ID",image_id)
vm.custom_set("Snapshot Name","#{snapshot_name}")

exit MIQ_OK
