# Author:: Kazuhiro Suzuki (<ksauzzmsg@gmail.com>)
# Copyright:: Copyright (c) 2014 Kazuhiro Suzuki
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
    class CloudstackVolumeDelete < Knife

      include Knife::CloudstackBase
      banner "knife cloudstack volume delete VOLUME_ID"

      def run

        if @name_args.nil? || @name_args.empty?
          puts "#{ui.color("Please provide an Volume ID.", :red)}"
        end

        @name_args.each do |volume_id|
          volume = connection.list_volumes('id' => volume_id)['listvolumesresponse']['volume'].first
          volume_id = volume['id'].to_s
          volume_name = volume['name'].to_s
          volume_size = (volume['size']/1024/1024/1024).to_s
          volume_type = volume['type']

          puts "#{ui.color("Id", :red)}: #{volume_id}"
          puts "#{ui.color("Name", :red)}: #{volume_name}"
          puts "#{ui.color("Size (in GB)", :red)}: #{volume_size}"
          puts "#{ui.color("Type", :red)}: #{volume_type}"
          puts "\n"
          confirm("#{ui.color("Do you really want to delete this volume", :red)}")
          connection.delete_volume('id' => volume_id)
          ui.warn("Deleted volume #{volume_name}")
        end
      end
    end
  end
end
