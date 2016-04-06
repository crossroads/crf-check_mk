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

include_recipe 'xinetd::default'

unless Chef::Config[:solo]
  check_mk_servers = []
  search(:node, "role:check_mk_server") do |n|
    check_mk_servers << n['ipaddress']
  end
end

package 'check-mk-agent' do
  action :upgrade
end

template '/etc/xinetd.d/check-mk-agent' do
  source 'check-mk-agent.erb'
  variables ( {
    :check_mk_servers => check_mk_servers
  } )
  notifies :restart, 'service[xinetd]'
end

check_mk_servers.each do |source|
  firewall_rule "check_mk-agent-ports-#{source}" do
    protocol  :tcp
    port      node['check_mk']['client']['port']
    source    source
  end
end

