#
# Cookbook Name:: crf-check_mk
# Recipe:: server
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
include_recipe 'apache2'
include_recipe 'apache2::mod_rewrite'
include_recipe 'apache2::mod_ssl'
include_recipe 'apache2::mod_filter'
include_recipe 'apache2::mod_access_compat'
include_recipe 'apache2::mod_cgi'

%w{ time traceroute boost-program-options dialog fping graphviz graphviz-gd libevent libmcrypt libtool-ltdl net-snmp net-snmp-utils pango perl-Net-SNMP php-mbstring php-pdo php-gd uuid xinetd xorg-x11-server-Xvfb python-ldap freeradius-utils }.each do |pkg|
  package pkg do
    action :upgrade
  end
end

remote_file "#{Chef::Config['file_cache_path']}/#{node['check_mk']['package_name']}" do
  source   node['check_mk']['package_url']
  checksum node['check_mk']['package_sha256']
end

yum_package 'omd' do
  source "#{Chef::Config['file_cache_path']}/#{node['check_mk']['package_name']}"
  action :install
end

firewall_rule 'check_mk-ports' do
  protocol  :tcp
  port      [80, 443]
end

# Create the certificates.
certificate_manage 'check_mk' do
  data_bag      node['check_mk']['certificate']['data_bag']
  data_bag_type node['check_mk']['certificate']['data_bag_type']
  search_id     node['check_mk']['certificate']['search_id']
  cert_file     node['check_mk']['certificate']['cert_file']
  key_file      node['check_mk']['certificate']['key_file']
  chain_file    node['check_mk']['certificate']['chain_file']
end

node['check_mk']['sites'].each do |site|
  execute "create-omd-#{site}" do
    command "/usr/bin/omd create #{site}"
    notifies :restart, 'service[apache2]'
    not_if do File.directory?("/opt/omd/sites/#{site}") end
  end

  execute "omd-fix-permissions-#{site}" do
    command "find /omd/sites/#{site}/etc -exec chmod g+w \\{} \\;"
  end
end

template "#{node['apache']['dir']}/sites-available/check_mk.conf" do
  source 'apache2.conf.erb'
  owner  node['apache']['user']
  group  node['apache']['user']
  mode   '0640'
  backup false
  notifies :restart, 'service[apache2]'
end

apache_site 'check_mk' do
  enable true
end

