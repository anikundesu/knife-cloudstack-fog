# Author:: Chirag Jog (<chirag@clogeny.com>)
# Copyright:: Copyright (c) 2011 Clogeny Technologies.
# License:: Apache License, Version 2.0
#
# Author:: Jeff Moody (<jmoody@datapipe.com>)
# Copyright:: Copyright (c) 2012 Datapipe
# License:: Apache License, Version 2.0
#
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Copyright:: Copyright (c) 2011 Opscode, Inc.
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
    class CloudstackInstanceList < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack instance list (options)"

      def run
        $stdout.sync = true

        validate!

        instance_list = [
          ui.color('Instance ID', :bold),
          ui.color('Display Name', :bold),
          ui.color('IP Address', :bold),
          ui.color('Security Group', :bold),
          ui.color('Instance Zone', :bold),
          ui.color('Service Offering', :bold),
          ui.color('Template', :bold),
          ui.color('State', :bold)
        ]
        
        response = connection.list_virtual_machines['listvirtualmachinesresponse']
        if virtual_machines = response['virtualmachine']
          virtual_machines.each do |instance|
              instance_list << instance['name'].to_s
              instance_list << instance['displayname'].to_s
              ip_list = []
              instance['nic'].each do |nic|
                ip_list << nic['ipaddress'].to_s
              end
              instance_list << ip_list.join(", ")
              sg_list = []
              instance['securitygroup'].each do |group|
                sg_list << group['name'].to_s
              end
              instance_list << sg_list.join(", ")
              
              instance_list << instance['zonename'].to_s
              instance_list << instance['serviceofferingname'].to_s
              instance_list << instance['templatedisplaytext'].to_s
              
              instance_list << begin
                state = instance['state'].to_s.downcase
                case state
                  when 'shutting-down','terminated','stopping','stopped'
                    ui.color(state, :red)
                  when 'pending', 'starting'
                    ui.color(state, :yellow)
                  else
                    ui.color(state, :green)
                end
              end
              
          end
          
          puts ui.list(instance_list, :columns_across, 8)
        end
      end
    end
  end
end