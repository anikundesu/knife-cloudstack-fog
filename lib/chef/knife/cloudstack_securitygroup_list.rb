# Author:: Jeff Moody (<jmoody@datapipe.com>)
# Copyright:: Copyright (c) 2012 Datapipe
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


require 'chef/knife/cloudstack_base'

class Chef
  class Knife
    class CloudstackSecuritygroupList < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack securitygroup list (options)"
      option :groupid,
             :short => "-g GROUPID",
             :long => "--groupid GROUPID",
             :description => "List the rules contained within a Security Group, specified by ID",
             :default => 'none'
      option :groupname,
             :short => "-G GROUPNAME",
             :long => "--groupname GROUPNAME",
             :description => "List the rules contained within a Security Group, specified by name.",
             :default => 'none'

      def sg_details_list(securitygroup_list, securitygroup_details, groups, options={})
        temp = groups
        if groupid = options[:groupid]
          temp.reject!{|g| g['id'] != groupid.to_i}
        end
        if groupname = options[:groupname]
          temp.reject!{|g| g['name'] != groupname}
        end
        
        temp.each do |securitygroup|
          securitygroup_list << securitygroup['id'].to_s
          securitygroup_list << securitygroup['name'].to_s
          securitygroup_list << securitygroup['description'].to_s
          if securitygroup['ingressrule'].nil?
            securitygroup_details << ' '
          else
            securitygroup['ingressrule'].each do |ingressrule|
              rule_details = []
              securitygroup_details << ingressrule['protocol'].to_s
              securitygroup_details << ingressrule['startport'].to_s
              securitygroup_details << ingressrule['endport'].to_s
              if ingressrule['cidr'].nil?
                rule_details << ingressrule['securitygroupname'].to_s
                rule_details << ingressrule['account'].to_s
              else
                rule_details << ingressrule['cidr'].to_s
              end
              securitygroup_details << rule_details.join(", ")
            end
          end
        end
      end
            
      def run
        $stdout.sync = true

        validate!
        groupid = locate_config_value(:groupid)
        groupname = locate_config_value(:groupname)

        if (groupid == 'none' and groupname == 'none')
          securitygroup_list = [
            ui.color('ID', :bold),
            ui.color('Name', :bold),
            ui.color('Description', :bold)
          ]
          response = connection.list_security_groups['listsecuritygroupsresponse']
            if securitygroups = response['securitygroup']
              securitygroups.each do |securitygroup|
                securitygroup_list << securitygroup['id'].to_s
                securitygroup_list << securitygroup['name'].to_s
                securitygroup_list << securitygroup['description'].to_s
              end
            end
          puts ui.list(securitygroup_list, :columns_across, 3)
        else
          securitygroup_details = [
            ui.color('Protocol', :bold),
            ui.color('Start Port', :bold),
            ui.color('End Port', :bold),
            ui.color('Restricted To', :bold)
          ]
          securitygroup_list = [
            ui.color('ID', :bold),
            ui.color('Name', :bold),
            ui.color('Description', :bold)
            ]
                        
            if response = connection.list_security_groups['listsecuritygroupsresponse']
              if securitygroups = response['securitygroup']
                filters = {}
                filters[:groupid] = groupid unless groupid == 'none'
                filters[:groupname] = groupname unless groupname == 'none'
                sg_details_list(securitygroup_list, securitygroup_details, securitygroups, filters)
                
                puts ui.list(securitygroup_list, :columns_across, 3)
                puts ui.list(securitygroup_details, :columns_across, 4)
              end
            end
            
        end
      end
       
    end
  end
end