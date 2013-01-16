# Author:: Takashi Kanai (<anikundesu@gmail.com>)
# Copyright:: Copyright (c) 2012 IDC Frontier Inc.
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
    class CloudstackPublicipList < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack publicip list"

      def run
        $stdout.sync = true

        validate!

        publicip_list = [
          ui.color('ID', :bold),
          ui.color('ipaddress', :bold),
          ui.color('isSourceNAT', :bold),
          ui.color('isStaticNAT', :bold),
          ui.color('VirtualMachineDisplayName', :bold)
        ]
        response = connection.list_public_ip_addresses['listpublicipaddressesresponse']
          if publicips = response['publicipaddress']
            publicips.each do |publicip|
              publicip_list << publicip['id'].to_s
              publicip_list << publicip['ipaddress'].to_s
              publicip_list << publicip['issourcenat'].to_s
              publicip_list << publicip['isstaticnat'].to_s
              publicip_list << publicip['virtualmachinedisplayname'].to_s
            end
          end
        puts ui.list(publicip_list, :columns_across, 5)

      end

    end
  end
end