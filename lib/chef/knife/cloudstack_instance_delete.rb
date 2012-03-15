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
    class CloudstackInstanceDelete < Knife
      deps do
        require 'fog'
        require 'readline'
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end
      
      banner "knife cloudstack server delete INSTANCE_ID [INSTANCE_ID] (options)"
      
      def run

        validate!

        @name_args.each do |instance_id|
          instance = connection.list_virtual_machines('name' => instance_id)
          
          puts "#{ui.color("Name", :red)}: #{instance['name'].to_s}"
          puts "#{ui.color("Public IP", :red)}: #{instance['ipaddress'].to_s}"

          puts "\n"
          confirm("Do you really want to delete this server?")

          connection.destroy_virtual_machine(instance_id)

          ui.warn("Deleted server #{instance['name'].to_s}")
        end
      end
      
      
    end
  end
end