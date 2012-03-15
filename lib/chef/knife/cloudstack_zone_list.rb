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
    class CloudstackZoneList < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack zone list (options)"
            
      def run
        $stdout.sync = true

        validate!

        zone_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Network Type', :bold),
          ui.color('Security Groups?', :bold)
        ]
        response = connection.list_zones['listzonesresponse']
          if zones = response['zone']
            zones.each do |zone|
              zone_list << zone['id'].to_s
              zone_list << zone['name'].to_s
              zone_list << zone['networktype'].to_s
              zone_list << begin
                state = zone['securitygroupsenabled'].to_s.downcase
                case state
                  when 'false'
                    ui.color('No', :red)
                  else
                    ui.color('Yes', :green)
                end
              end
            end
          end
        puts ui.list(zone_list, :columns_across, 4)

      end
        
    end
  end
end