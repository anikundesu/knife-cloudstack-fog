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
    class CloudstackServiceofferingList < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack serviceoffering list (options)"
            
      def run
        $stdout.sync = true

        validate!

        serviceoffering_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Description', :bold),
          ui.color('Number of CPUs', :bold),
          ui.color('CPU Speed', :bold),
          ui.color('Memory (in MB)', :bold),
          ui.color('Network Speed', :bold)
        ]
        response = connection.list_service_offerings['listserviceofferingsresponse']
          if serviceofferings = response['serviceoffering']
            serviceofferings.each do |serviceoffering|
              serviceoffering_list << serviceoffering['id'].to_s
              serviceoffering_list << serviceoffering['name'].to_s
              serviceoffering_list << serviceoffering['description'].to_s
              serviceoffering_list << serviceoffering['cpunumber'].to_s
              serviceoffering_list << serviceoffering['cpuspeed'].to_s
              serviceoffering_list << serviceoffering['memory'].to_s
              serviceoffering_list << serviceoffering['networkrate'].to_s
            end
          end
        puts ui.list(serviceoffering_list, :columns_across, 7)

      end
        
    end
  end
end