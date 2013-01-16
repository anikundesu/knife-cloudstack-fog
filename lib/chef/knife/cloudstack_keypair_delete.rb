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
    class CloudstackKeypairDelete < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack keypair delete NAME"


      def run
        if @name_args.nil?
          puts #{ui.color("Please provide a keypair name.", :red)}
        end

        @name_args.each do |keypair_name|
          response = connection.list_ssh_key_pairs('name' => keypair_name)
          fingerprint = response['listsshkeypairsresponse']['sshkeypair'].first['fingerprint']
          real_keypair_name = response['listsshkeypairsresponse']['sshkeypair'].first['name']
          puts "#{ui.color("Name", :red)}: #{real_keypair_name}"
          puts "#{ui.color("Fingerprint", :red)}: #{fingerprint}"
          puts "\n"
          confirm("#{ui.color("Do you really want to delete this keypair?", :red)}")
          connection.delete_ssh_key_pair(real_keypair_name)
          ui.warn("Deleted SSH keypair #{real_keypair_name}")
        end
      end
    end
  end
end