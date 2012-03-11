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
    class CloudstackZonesList < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack zones list (options)"
            
      def run
        $stdout.sync = true

        validate!

        zone_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Description', :bold),
          ui.color('Disk Size (in GB)', :bold)
        ]
        response = connection.list_zones['listzonesresponse']
        puts response
          if zones = response['zone']
            zones.each do |zone|
              zone_list << zone['id'].to_s
              zone_list << zone['name'].to_s
              zone_list << zone['displaytext'].to_s
              disk_size = zone['disksize']
              zone_list << disk_size.to_s

            end
          end
        puts ui.list(zone_list, :columns_across, 4)

      end
        
    end
  end
end