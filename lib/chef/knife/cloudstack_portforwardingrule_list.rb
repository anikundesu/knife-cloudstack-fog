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
    class CloudstackPortforwardingruleList < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack portforwardingrule list (options)"

      def run
        $stdout.sync = true

        validate!

        rule_list = [
          ui.color('ID', :bold),
          ui.color('PublicIPID', :bold),
          ui.color('PublicIP', :bold),
          ui.color('PublicPort', :bold),
          ui.color('PrivatePort', :bold),
          ui.color('Protocol', :bold),
          ui.color('VirtualMachineID', :bold),
          ui.color('VirtualMachineName', :bold)
        ]
        response = connection.list_port_forwarding_rules['listportforwardingrulesresponse']
          if rules = response['portforwardingrule']
            rules.each do |rule|
              rule_list << rule['id'].to_s
              rule_list << rule['ipaddressid'].to_s
              rule_list << rule['ipaddress'].to_s
              rule_list << rule['publicport'].to_s
              rule_list << rule['privateport'].to_s
              rule_list << rule['protocol'].to_s
              rule_list << rule['virtualmachineid'].to_s
              rule_list << rule['virtualmachinename'].to_s
            end
          end
        puts ui.list(rule_list, :columns_across, 8)

      end

    end
  end
end