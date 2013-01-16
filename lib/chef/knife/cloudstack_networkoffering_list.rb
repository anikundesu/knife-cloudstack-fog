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
    class CloudstackNetworkofferingList < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack networkoffering list (options)"
            
      def run
        $stdout.sync = true

        validate!

        network_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Display Name', :bold),
          ui.color('Traffic Type', :bold),
          ui.color('State', :bold),
          ui.color('Service Offering ID', :bold)
        ]

        response = connection.list_network_offerings['listnetworkofferingsresponse']

        if networks = response['networkoffering']
          
          networks.each do |networkoffering|
            # puts networkoffering
            network_list << networkoffering['id'].to_s
            network_list << networkoffering['name'].to_s
            network_list << networkoffering['displaytext'].to_s
            network_list << networkoffering['traffictype'].to_s
            network_list << begin
              state = networkoffering['state'].to_s.downcase
              case state
                when 'allocated'
                  ui.color(state, :red)
                when 'pending'
                  ui.color(state, :yellow)
                else
                  ui.color(state, :green)
              end
            end
            network_list << networkoffering['serviceofferingid'].to_s
          end
        end

        puts ui.list(network_list, :uneven_columns_across, 6)

      end
        
    end
  end
end