# Author:: Chirag Jog (<chirag@clogeny.com>)
# Copyright:: Copyright (c) 2011 Clogeny Technologies.
# License:: Apache License, Version 2.0
#
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
    class CloudstackServerList < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack server list (options)"
      option :zoneid,
             :short => "-z ZONEID",
             :long => "--zoneid ZONEID",
             :description => "Limit responses to servers only running in a specific zone (specified by ID #). Default provides servers from all zones.",
             :default => "all"
      option :state,
             :short => "-s STATE",
             :long => "--state STATE",
             :description => "Limit responses to servers only of a given state. Possible values are 'running,' 'stopped,' 'starting,' 'pending,' 'shutting-down,' 'terminated,' and 'stopping.' Default provides servers in all states.",
             :default => "all"
             
      def print_servers(server_list,servers,options={})
        server = servers
        if zoneid = options[:zoneid]
          server.reject!{|t| t['zoneid'] != zoneid.to_i}
        end
        if state = options[:state]
          state.downcase!
          server.reject!{|t| t['state'].downcase != state}
        end
        
        server.each do |instance|
          server_list << instance['name'].to_s
          server_list << instance['displayname'].to_s
          ip_list = []
          instance['nic'].each do |nic|
            ip_list << nic['ipaddress'].to_s
          end
          server_list << ip_list.join(", ")
          sg_list = []
          instance['securitygroup'].each do |group|
            sg_list << group['name'].to_s
          end
          server_list << sg_list.join(", ")
          
          server_list << instance['zonename'].to_s
          server_list << instance['serviceofferingname'].to_s
          server_list << instance['templatedisplaytext'].to_s
          server_list << instance['hypervisor'].to_s
          
          server_list << begin
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
        
      end

      def run
        $stdout.sync = true

        validate!

        server_list = [
          ui.color('Server ID', :bold),
          ui.color('Display Name', :bold),
          ui.color('IP Address', :bold),
          ui.color('Security Group', :bold),
          ui.color('Server Zone', :bold),
          ui.color('Service Offering', :bold),
          ui.color('Template', :bold),
          ui.color('Hypervisor', :bold),
          ui.color('State', :bold)
        ]
        
        zoneid = locate_config_value(:zoneid)
        state = locate_config_value(:state)
        
        response = connection.list_virtual_machines['listvirtualmachinesresponse']
        if virtual_machines = response['virtualmachine']
          filters = {}
          filters[:zoneid] = zoneid unless zoneid == 'all'
          filters[:state] = state unless state == 'all'
          print_servers(server_list, virtual_machines, filters)
          puts ui.list(server_list, :uneven_columns_across, 9)
        end
      end
    end
  end
end