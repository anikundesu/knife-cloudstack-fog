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

      banner "knife cloudstack network create -n NAME -o NETWORKOFFERINGID -z ZONE (options)"

      option  :name,
              :short => "-n NAME",
              :long => "--name NAME",
              :description => "The name of the network to create."

      option  :networkoffering,
              :short => "-o NETWORKOFFERINGID",
              :long => "--networkoffering NETWORKOFFERINGID",
              :description => "The network service offering ID to use."

      option  :zone,
              :short => "-z ZONE",
              :long => "--zone ZONE",
              :description => "The zone to create the network in."

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

      option  :gateway,
              :short => "-g GATEWAY",
              :long => "--gateway GATEWAY",
              :description => "The gateway for the network."

      option  :vlan,
              :short => "-l VLANID",
              :long => "--vlan VLANID",
              :description => "The VLAN for the network."

      option :displaytext,
             :short => "-i DISPLAYTEXT",
             :long => "--displaytext DISPLAYTEXT",
             :description => "The display name of the network, if different than the name."


      def run
        $stdout.sync = true

        validate!

        netoptions = {}
        mandatoryoptions = {}

          if (locate_config_value(:name).nil? || locate_config_value(:networkoffering).nil? || locate_config_value(:zone).nil?)
            puts "Name (-n), Service Offering ID (-o), and Zone ID (-z) are required."
          else
            mandatoryoptions['name'] = locate_config_value(:name)
            mandatoryoptions['networkofferingid'] = locate_config_value(:networkoffering)
            mandatoryoptions['zoneid'] = locate_config_value(:zone)

            if locate_config_value(:startip) != nil
              netoptions['startip'] = locate_config_value(:startip)
            end

            if locate_config_value(:endip) != nil
              netoptions['endip'] = locate_config_value(:endip)
            end

            if locate_config_value(:netmask) != nil
              netoptions['netmask'] = locate_config_value(:netmask)
            end

            if locate_config_value(:gateway) != nil
              netoptions['gateway'] = locate_config_value(:gateway)
            end

            if locate_config_value(:vlan) != nil
              netoptions['vlan'] = locate_config_value(:vlan)
            end

            if locate_config_value(:displaytext) != nil
              mandatoryoptions['displaytext'] = locate_config_value(:displaytext)
            else
              mandatoryoptions['displaytext'] = locate_config_value(:name)
            end

            Chef::Log.debug("Options: #{netoptions}")

            response = connection.create_network(mandatoryoptions['displaytext'], mandatoryoptions['name'], mandatoryoptions['networkofferingid'], mandatoryoptions['zoneid'], netoptions)

            Chef::Log.debug("API Response: #{response}")

            network_list = [
              ui.color('ID', :bold),
              ui.color('Name', :bold),
              ui.color('Display Text', :bold),
              ui.color('Zone ID', :bold),
              ui.color('VLAN', :bold),
              ui.color('State', :bold)
            ]

            newnetwork = response['createnetworkresponse']['network']

            network_list << newnetwork['id'].to_s
            network_list << newnetwork['name'].to_s
            network_list << newnetwork['displaytext'].to_s
            network_list << newnetwork['zoneid'].to_s
            network_list << newnetwork['vlan'].to_s
            network_list << newnetwork['state'].to_s

            puts ui.list(network_list, :columns_across, 6)

          end

      end

    end
  end
end
