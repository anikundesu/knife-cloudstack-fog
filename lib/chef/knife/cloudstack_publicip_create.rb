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
    class CloudstackPublicipCreate < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack publicip create (options)"

      option  :zoneid,
              :short => "-z ZONEID",
              :long => "--zoneid ZONEID",
              :description => "[REQUIRED]The CloudStack zone ID to create new public IP."

      option  :networkid,
              :long => "--network-id NETWORKID",
              :description => "[OPTIONAL]The CloudStack network ID to crate new public IP."

      def run
        $stdout.sync = true

        validate!

        options = {}

        if locate_config_value(:networkid) != nil
          options['networkid']=locate_config_value(:networkid)
        end

        if locate_config_value(:zoneid) != nil
          options['zoneid']=locate_config_value(:zoneid)

          publicip_list = [
            ui.color('ID', :bold),
            ui.color('ipaddress', :bold),
            ui.color('isSourceNAT', :bold),
            ui.color('isStaticNAT', :bold)
          ]

          response = connection.acquire_ip_address(options)
          publicipid = response['associateipaddressresponse']['id']
          jobid = response['associateipaddressresponse'].fetch('jobid')

          publicip_assign = connection.query_async_job_result('jobid'=>jobid)
          print "#{ui.color("Waiting for assigning Public IP", :magenta)}"
          while publicip_assign['queryasyncjobresultresponse'].fetch('jobstatus') != 1
            print "#{ui.color(".", :magenta)}"
            sleep(5)
            publicip_assign = connection.query_async_job_result('jobid'=>jobid)
          end
          puts "\n\n"

          publicip_assign = connection.query_async_job_result('jobid'=>jobid)
          publicip = publicip_assign['queryasyncjobresultresponse']['jobresult']['ipaddress']

          publicip_list << publicip['id'].to_s
          publicip_list << publicip['ipaddress'].to_s
          publicip_list << publicip['issourcenat'].to_s
          publicip_list << publicip['isstaticnat'].to_s

          puts ui.list(publicip_list, :columns_across, 4)

        else
          puts 'Error. Missing Zone ID (-z).'
        end

      end

    end
  end
end
