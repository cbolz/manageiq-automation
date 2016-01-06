#!/usr/bin/env ruby
#
#
# Description: Create AMI Image for cloudforms provisioning
#
# Description: Create snapshot of currently selected instance
#http://www.mediamolecule.com/blog/article/using_ebs_snapshots_with_fog
#
=begin
changelog:
2. adding snapshot prefix with date string
1. refer from: http://www.mediamolecule.com/blog/article/using_ebs_snapshots_with_fog
 
=end

@method = 'create_aws_ebs_snapshot'

$evm.log("info", "#{@method} - EVM Automate Method Started")

require 'rest-client'
require 'json'
require 'fog'

# make sure to adjust the openstack_tenant or make it dynamic
vm = $evm.root['vm']
ext_mgt_system=vm.ext_management_system
credentials={
  :provider => "AWS",
  :region => ext_mgt_system.provider_region,
  :aws_access_key_id => ext_mgt_system.authentication_userid,
  :aws_secret_access_key => ext_mgt_system.authentication_password
}

$evm.log("info", "#{@method} - Logging into to http://#{ext_mgt_system[:hostname]}:#{ext_mgt_system[:port]}/v2.0/tokens as #{ext_mgt_system.authentication_userid}")
# Make a connection to AWS
#@fog = Fog::Compute.new(:provider => 'AWS', :region => region, :aws_access_key_id => fog_creds.access, :aws_secret_access_key => fog_creds.secret)
# Grab an unfiltered list of all of the volumes
#volumes  = @fog.volumes.all

# Create a new snapshot transaction. It needs a description and a volume id to snapshot
@fog = Fog::Compute.new(credentials)
server = @fog.servers.get(vm.ems_ref)
snapshot = @fog.snapshots.new
snapshot.description = "#"
snapshot.volume_id = server.name
#snapshot.volume_id = vol.id

# Now actually take the snapshot
response = snapshot.save
response.wait_for { ready? }
$evm.log("info", "#{@method} - Created Snapshot named")

vm.custom_set("snapshot.methods","#{snapshot.methods}")
vm.custom_set("server.name","#{server.name}")

############ ykim

#compute = Fog::Compute.new(credentials)
#server = compute.servers.get(vm.ems_ref)
#snapshot_prefix = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
#
#response = server.create_image "#{snapshot_prefix}-#{server.name}", :metadata => { :environment => 'development' }
#snapshot_name = "#{snapshot_prefix}-#{server.name}"
#image_id = response.body["image"]["id"]
#
#$evm.log("info", "#{@method} - Created Snapshot named #{snapshot_name} with ID #{image_id}")

#vm.custom_set("Snapshot ID",image_id)
#vm.custom_set("Snapshot Name","#{snapshot_name}")

exit MIQ_OK
