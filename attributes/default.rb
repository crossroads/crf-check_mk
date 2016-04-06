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

default['check_mk']['hostname']                     = 'check_mk'
default['check_mk']['domainname']                   = "#{node['check_mk']['hostname']}.#{node['domain']}"
default['check_mk']['base_path']                    = 'check_mk'
default['check_mk']['bind_address']                 = '*'
default['check_mk']['sites']                        = [ "#{node.chef_environment}" ]
default['check_mk']['certificate']['data_bag']      = nil
default['check_mk']['certificate']['data_bag_type'] = 'unencrypted'
default['check_mk']['certificate']['search_id']     = 'check_mk'
default['check_mk']['certificate']['cert_file']     = "#{node['fqdn']}.pem"
default['check_mk']['certificate']['key_file']      = "#{node['fqdn']}.key"
default['check_mk']['certificate']['chain_file']    = "#{node['hostname']}-bundle.crt"

default['check_mk']['package_name']                 = 'omd-1.20.rhel7.x86_64.rpm'
default['check_mk']['package_url']                  = 'http://files.omdistro.org/releases/centos_rhel/omd-1.20.rhel7.x86_64.rpm' 
default['check_mk']['package_sha256']               = '9bde358c3a8f1eac1c2d2a89f6399cf5e22a2ea66cbceafdd6b3537fb9e1a1bd'
