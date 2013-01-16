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
    class CloudstackNetworkList < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack network list (options)"
            
      def run
        $stdout.sync = true

        validate!

        network_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Zone ID', :bold),
          ui.color('VLAN', :bold),
          ui.color('State', :bold)
        ]
        response = connection.list_networks['listnetworksresponse']
          if networks = response['network']
            networks.each do |network|
              network_list << network['id'].to_s
              network_list << network['name'].to_s
              network_list << network['zoneid'].to_s
              network_list << network['vlan'].to_s
              network_list << begin
                state = network['state'].to_s.downcase
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
          end
        puts ui.list(network_list, :columns_across, 5)

      end
        
    end
  end
end