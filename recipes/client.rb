#
# Cookbook Name:: crf-check_mk
# Recipe:: default
#
# Copyright (C) 2016 Crossroads Foundation Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe 'yum-epel::default'
include_recipe 'firewall'
include_recipe 'systemd'

check_mk_servers = []
unless Chef::Config[:solo]
  search(:node, "role:check_mk_server") do |n|
    check_mk_servers << n['ipaddress']
  end
end

package 'check-mk-agent' do
  action :upgrade
end

systemd_socket 'check_mk_agent' do
  description 'Check_MK Socket for Per-Connection Servers'
  conflicts 'check_mk_agent.service'
  install do
    wanted_by 'sockets.target'
  end
  socket do
    listen_stream node['check_mk']['client']['port']
    accept true
  end
  action [:create, :enable, :start]
end

systemd_service 'check_mk_agent@' do
  description 'Check_MK Per-Connection Server'
  service do
    exec_start '/usr/bin/check_mk_agent'
    standard_input 'socket'
  end
end

# Firewall rules for the Check MK agent service
check_mk_servers.each do |source|
  firewall_rule "check_mk-agent-ports-#{source}" do
    protocol  :tcp
    port      node['check_mk']['client']['port']
    source    source
  end
  firewall_rule "check_mk-agent-ping-#{source}" do
    protocol  :icmp
    source    source
  end
end

# Include postgresql CheckMK plugin
link '/usr/share/check-mk-agent/plugins/mk_postgres' do
  to '/usr/share/check-mk-agent/available-plugins/mk_postgres'
  link_type :symbolic
  only_if { node.recipe?('postgresql::server') }
end

# Clean up legacy files
template '/etc/xinetd.d/check-mk-agent' do
  action :delete
end
template '/etc/xinetd.d/check-mk-caching-agent' do
  action :delete
end
