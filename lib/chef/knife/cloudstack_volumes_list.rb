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
    class CloudstackVolumeList < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack volume list (options)"
            
      def run
        $stdout.sync = true

        validate!

        volume_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Size (in GB)', :bold),
          ui.color('Type', :bold),
          ui.color('Virtual Machine', :bold),
          ui.color('State', :bold)
        ]
        
        response = connection.list_volumes['listvolumesresponse']
        
        if volumes = response['volume']
          volumes.each do |volume|
            volume_list << volume['id'].to_s
            volume_list << volume['name'].to_s
            volume_size = volume['size']
            volume_size = (volume_size/1024/1024/1024)
            volume_list << volume_size.to_s
            volume_list << volume['type']
            if (volume['vmdisplayname'].nil?)
              volume_list << ' '
            else
              volume_list << volume['vmdisplayname']
            end
            
            volume_list << begin
              state = volume['state'].to_s.downcase
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
          puts ui.list(volume_list, :columns_across, 6)
        end

      end
        
    end
  end
end