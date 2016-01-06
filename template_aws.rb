#!/usr/bin/env ruby
#
# Description: <Method description here>
#
# Description: Create ami template of currently selected instance
#https://gist.github.com/jedi4ever/955604
#

@method = 'create_aws_ebs_snapshot'

$evm.log("info", "#{@method} - EVM Automate Method Started")

require 'rest-client'
require 'json'
require 'fog'

# make sure to adjust the openstack_tenant or make it dynamic
t = Time.now
stamp = t.strftime("%Y%m%d.%M%H")
day = t.strftime("%Y%m%d")
TemplateName = $evm.root['dialog_TemplateName']

vm = $evm.root['vm']
ext_mgt_system=vm.ext_management_system
credentials={
  :provider => "AWS",
  :region => ext_mgt_system.provider_region,
  :aws_access_key_id => ext_mgt_system.authentication_userid,
  :aws_secret_access_key => ext_mgt_system.authentication_password
}

$evm.log("info", "#{@method} - Logging into to http://#{ext_mgt_system[:hostname]}:#{ext_mgt_system[:port]}/v2.0/tokens as #{ext_mgt_system.authentication_userid}")


# Create a new snapshot transaction. It needs a description and a volume id to snapshot
compute = Fog::Compute.new(credentials)
server = compute.servers.get(vm.ems_ref)

response = compute.create_image("#{server.id}","#{TemplateName}", "Created at #{stamp} from #{server.id}")


$evm.log("info", "#{@method} - Created AMI Template named")

vm.custom_set("response.methods","#{response.methods}")

exit MIQ_OK
