# Author:: Jeff Moody (<jmoody@datapipe.com>)
# Copyright:: Copyright (c) 2013 Datapipe
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
    class CloudstackNetworkDelete < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack network delete ID"


      def run
        if @name_args.nil?
          puts #{ui.color("Please provide a network ID.", :red)}
        end

        @name_args.each do |network_id|
          response = connection.list_networks('id' => network_id)
          
          apiresponse = response['listnetworksresponse']
          network = apiresponse['network']
          Chef::Log.debug("Network: #{network}")
          network_name = network[0]['name'].to_s
          network_display = network[0]['displaytext'].to_s
          puts "#{ui.color("Name", :red)}: #{network_name}"
          puts "#{ui.color("Display Text", :red)}: #{network_display}"
          puts "\n"
          confirm("#{ui.color("Do you really want to delete this network?", :red)}")
          connection.delete_network(network_id)
          ui.warn("Deleted network #{network_name}")
        end
      end
    end
  end
end