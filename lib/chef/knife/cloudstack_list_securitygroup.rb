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
      option :rules,
             :short => "-D GroupID",
             :long => "--rules GroupID",
             :description => "List the rules contained within a Security Group",
            
      def run
        $stdout.sync = true

        validate!

        securitygroup_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Description', :bold)
#          ui.color('Rules', :bold)
        ]
        response = connection.list_security_groups['listsecuritygroupsresponse']
          if securitygroups = response['securitygroup']
            securitygroups.each do |securitygroup|
              securitygroup_list << securitygroup['id'].to_s
              securitygroup_list << securitygroup['name'].to_s
              securitygroup_list << securitygroup['description'].to_s
#              rule_list = []
#              if securitygroup['ingressrule'].nil?
#                rule_list << ' '
#              else
#                securitygroup['ingressrule'].each do |ingressrule|
#                  rule_details = []
#                  rule_details << ingressrule['protocol'].to_s
#                  rule_details << ingressrule['startport'].to_s
#                  rule_details << ingressrule['endport'].to_s
#                  if ingressrule['cidr'].nil?
#                    rule_details << ingressrule['securitygroupname'].to_s
#                    rule_details << ingressrule['account'].to_s
#                  else
#                    rule_details << ingressrule['cidr'].to_s
#                  end
#                  rule_list << rule_details.join(", ")
#                end
#              end
#              securitygroup_list << rule_list.join("\n\t")
            end
          end
        puts ui.list(securitygroup_list, :columns_across, 3)

      end
        
    end
  end
end