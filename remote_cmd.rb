#
# Description: <Method description here>
#
# Description: Create snapshot of currently selected instance
#http://www.jung-christian.de/2015/12/create-snapshots-in-openstack/
#

@method = 'firewall_check_openstack'

$evm.log("info", "#{@method} - EVM Automate Method Started")

require 'rest-client'
require 'json'
require 'fog'

tenantName = "admin"
stamp = Time.now.strftime('%Y-%m-%d_%H-%M-%S')
ssh_username = "cirros"
ssh_private_key = "-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEA8C+cl9xC7zHxhojmDRrIQBHLi5vOCbmWgBVoxC5j8DyhsqUQ
rutm96JYP2F8JO1kS6aSg/obBNd+w151cso4YI/4DUd+AtiYBmlvCfp46sNrDXDb
R9LYbtPDA3L8YjcCvXBpjTokkZklA3F0L5N3ryrY/kuUZhs/vJwWqmyZXaTH6gWe
qD0c7SdAtwC5J7zRJJYmJZHvVYHxKRRVc1gCuSCHT204xGL6z/0jqfXPOFznWyLk
ZmZlMb/M3ib0xpde3koICHyfdQOrPEam+O9NA5EDwy1Bajpy5munSqXwuUa0JzZd
JrQgxJoI/MyN4pETd2FF1S0bQrgFKR1IJWOnzQIDAQABAoH/R03bLzo0pM4u5cG+
iiVpTZv60Xdvs3NlOqEgeR1MjgVx+5cFXOiFqP6JNEe8kznmjI7m8EdPviA7gcSJ
GYrvMbuL6GVRA4dJmp2yWUQCoa9iGJtofeoaVsyHGH8Kbh3mslas/0BDmvXcBymn
VHhzD42o3dWSOL3eLiAomm+jGCk/9Te1EbZZkakwTL4hMK7Q/zUVSRRauRBi+MK9
rcji11EcUjHBXivcypg7zp4hWwqqGtDGLRgx6jTp8Xi8EXhYaiXNugArlvvG1Mk/
dPcmGpuJqUB2pIf9GI2Tyv2wm3CqvcVSTi9vPWwqEKPkjtbnXAyuquDse7/5kxSq
lkQBAoGBAPhIMaQ2atOCRzp6IKmQogP8iCpCbjpASNoZQvOKsmsFtIUd1JZIgiL9
JgxMgoy/ra1TQAfFfsYqMysOARLV5/kr9aj0VfX88QMuy1JmSCWwz4ihGlqjVF1c
sz7yJu3uobyBr7SCouV08ID9o0YKDq46/pIgDgLZlJ72Fc79CF5BAoGBAPem/Ybz
xsUZ/ygN8tMvUKyNBvo6K6hGVwl3viPL7ct81/XwkaP1Y2+HMfRT2IXuAABGRPQ8
S2x4uP+fsRKl4+YVuLBYLb8PIkOfy+f2/LEx5F9H1dmomdoplHSnbIrhyRi4QxQs
dykJaCtoPaIgJeSQwOBzO2tm3nyveTAr9D6NAoGBAI96oP1l2SwrwF/hzdhP1eD5
4fKR+0M8fR1UteUqBNtmK6E10PGcK2Bu7Lr0yAjwiDx+vKUBE7cPEgzShfpNlUXg
ipG9yaNjLiCJvUP8CbuGRxiNCT7R3mIpvQgmRir/2YWnaFOnnt19S7MvYFiMXVmA
jDcDwTUSahnG2mmIvnpBAoGASMyE4GPOvWfr8plPFTdmbqKyN2JcLQYoVbcmZJ1w
1I1panmCRoE+7qz+SUVQc+ZHh80gPe9veH5wW2xVABdVy+/8r5HsOKq5NsnFhfW7
yFbTPBMA0Q/X0iLA6h3BMX43wBWCWm7LxHtobMIixALRQMQwfopBIExIAL0QUdHJ
5Y0CgYEAvSC8HOBwkM+a+RNw6jfr1aE5i3vMyub0H+D8QgpnrVGiNQJqBE4bT+ij
Ax5TlALdyULPuVowMXEmAf6gfHmjsxD3szy4/9sH3tCHLcUHLug1UF22c3HCjoi3
BrgtBo5ielsv0pKmQfc/GBw4RfsFhehJ84Y0N7jxIOyZjEy/BH4=
-----END RSA PRIVATE KEY-----"

#### ssh_command
#ssh_cmd = "df > ~/filesystem_check_#{stamp}.log"
ssh_cmd = $evm.root['dialog_command']
#ssh_ip_address = "localhost"

#end_user_defined

vm = $evm.root['vm']
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
server.username = ssh_username
server.private_key = ssh_private_key
server.ssh_ip_address = server.public_ip_address

response = server.ssh ["#{ssh_cmd}"]
$evm.log("info", "ykim, ssh_cmd_result: #{response}")


#response = server.create_image "#{snapshot_prefix}-#{server.name}", :metadata => { :environment => 'development' }
#snapshot_name = "#{snapshot_prefix}-#{server.name}"
#image_id = response.body["image"]["id"]

$evm.log("info", "#{@method} - Created firewall check with ID #{server.name}")

exit MIQ_OK
