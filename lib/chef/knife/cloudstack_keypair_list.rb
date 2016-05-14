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
    class CloudstackKeypairList < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack keypair list"

      def run
        $stdout.sync = true

        validate!

        sshkeypair_list = [
          ui.color('Name', :bold),
          ui.color('Fingerprint', :bold),
          ui.color('Private Key', :bold)
        ]
        response = connection.list_ssh_key_pairs['listsshkeypairsresponse']
          if sshkeypairs = response['sshkeypair']
            sshkeypairs.each do |sshkeypair|
              sshkeypair_list << sshkeypair['name'].to_s
              sshkeypair_list << sshkeypair['fingerprint'].to_s
              sshkeypair_list << sshkeypair['privatekey'].to_s
            end
          end
        puts ui.list(sshkeypair_list, :columns_across, 3)

      end

    end
  end
end
