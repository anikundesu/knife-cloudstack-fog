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
    class CloudstackKeypairCreate < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack keypair create -k NAME (options)"

      option  :name,
              :short => "-k KEYPAIR",
              :long => "--keypair KEYPAIR",
              :description => "The name of the Key Pair to create."

      option  :publickey,
              :short => "-p publickey",
              :long => "--public-key publickey",
              :description => "The public key to register."

      option  :outfile,
              :short => "-o FILENAME",
              :long => "--out-file FILENAME",
              :description => "The output filename of created private key."

      def run
        $stdout.sync = true

        validate!

        options = {}
        if locate_config_value(:publickey) != nil
          options['publickey'] = locate_config_value(:publickey)
          mode = 'register'
          if locate_config_value(:name) != nil
            options['name'] = locate_config_value(:name)
          end
        else
          mode = 'create'
          if locate_config_value(:name) != nil
            keypair_name = locate_config_value(:name)
          end
        end

        case mode
        when 'register'
          response = connection.register_ssh_key_pair(options)
          sshkeypair = response['registersshkeypairresponse']['keypair']

          sshkeypair_list = [
            ui.color('Name', :bold),
            ui.color('Fingerprint', :bold),
            ui.color('Private Key', :bold)
          ]

          sshkeypair_list << sshkeypair['name'].to_s
          sshkeypair_list << sshkeypair['fingerprint'].to_s
          sshkeypair_list << sshkeypair['privatekey'].to_s
          puts ui.list(sshkeypair_list, :columns_across, 3)
        when 'create'
          response = connection.create_ssh_key_pair(keypair_name,options)
          sshkeypair = response['createsshkeypairresponse']['keypair']

          if locate_config_value(:outfile) != nil
            output = locate_config_value(:outfile)
            File.open(output,'w'){|f|
              f.print sshkeypair['privatekey'].to_s
            }
          else
            sshkeypair_list = [
              ui.color('Private Key', :bold)
            ]
            sshkeypair_list << sshkeypair['privatekey'].to_s
            puts ui.list(sshkeypair_list, :columns_across, 3)
          end
        else
          puts 'Error. Missing Keypair Name (-k) option.'
        end

      end

    end
  end
end