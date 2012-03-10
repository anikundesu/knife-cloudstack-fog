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
    class CloudstackSecurityGroupList < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack securitygroup list (options)"
            
      def run
        $stdout.sync = true

        validate!

        securitygroup_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Size (in GB)', :bold),
          ui.color('Type', :bold),
          ui.color('Virtual Machine', :bold),
          ui.color('State', :bold)
        ]
        response = connection.list_securitygroups['listsecuritygroupsresponse']
        puts response
        
        if securitygroups = response['securitygroup']
          securitygroups.each do |securitygroup|
            securitygroup_list << securitygroup['id'].to_s
            securitygroup_list << securitygroup['name'].to_s
            securitygroup_size = securitygroup['size']
            securitygroup_size = (securitygroup_size/1024/1024/1024)
            securitygroup_list << securitygroup_size.to_s
            securitygroup_list << securitygroup['type']
            if (securitygroup['vmdisplayname'].nil?)
              puts "NULL VM"
              securitygroup_list << ' '
            else
              securitygroup_list << securitygroup['vmdisplayname']
            end
            
            securitygroup_list << begin
              state = securitygroup['state'].to_s.downcase
              case state
                when 'allocated'
                  ui.color(state, :red)
                when 'pending'
                  ui.color(state, :yellow)
                else
                  ui.color(state, :green)
              end
            end
          end
          puts ui.list(securitygroup_list, :columns_across, 6)
        end

      end
        
    end
  end
end