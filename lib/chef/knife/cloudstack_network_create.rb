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
    class CloudstackNetworkCreate < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack network create -n NAME -o SERVICEOFFERINGID -z ZONE (options)"

      option  :name,
              :short => "-n NAME",
              :long => "--name NAME",
              :description => "The name of the network to create."

      option  :serviceoffering,
              :short => "-o SERVICEOFFERINGID",
              :long => "--serviceoffering SERVICEOFFERINGID",
              :description => "The network service offering ID to use."

      option  :zone,
              :short => "-z ZONE",
              :long => "--zone ZONE",
              :description => "The zone to create the network in."

      option  :isdefault,
              :short => "-d DEFAULT",
              :long => "--default DEFAULT",
              :description => "Do we make this network a default or not? Boolean value."

      option  :startip,
              :short => "-s STARTIP",
              :long => "--startip STARTIP",
              :description => "The starting IP for the network."

      option  :endip,
              :short => "-e ENDIP",
              :long => "--endip ENDIP",
              :description => "The ending IP for the network."

      option  :netmask,
              :short => "-m NETMASK",
              :long => "--netmask NETMASK",
              :description => "The netmask for the network."


      def run
        $stdout.sync = true

        validate!

        puts "TODO"

      end

    end
  end
end