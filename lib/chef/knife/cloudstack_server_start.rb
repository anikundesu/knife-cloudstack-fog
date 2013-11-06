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
    class CloudstackServerStart < Knife

      include Knife::CloudstackBase
      banner "knife cloudstack server start INSTANCE_ID"

      def run

        if @name_args.nil? || @name_args.empty?
          puts "#{ui.color("Please provide an Instance ID.", :red)}"
        end

        jobs = {}
        batch_size = 5

        @name_args.each_slice(batch_size) do |batch|
          batch.each do |instance_id|
            response = connection.list_virtual_machines('name' => instance_id)
            instance_name = response['listvirtualmachinesresponse']['virtualmachine'].first['name']
            instance_ip = response['listvirtualmachinesresponse']['virtualmachine'].first['nic'].first['ipaddress']
            real_instance_id = response['listvirtualmachinesresponse']['virtualmachine'].first['id']
            puts "#{ui.color("Name", :green)}: #{instance_name}"
            puts "#{ui.color("Public IP", :green)}: #{instance_ip}"
            puts "\n"
            confirm("#{ui.color("Do you really want to start this server", :green)}")


            if locate_config_value(:force)
              server = connection.start_virtual_machine('id' => real_instance_id, 'forced' => true)
            else
              server = connection.start_virtual_machine('id' => real_instance_id)
            end
            jobid = server['startvirtualmachineresponse'].fetch('jobid')

            jobs[instance_id] = jobid
          end

          print "#{ui.color("Waiting for servers", :magenta)}"
          until jobs.empty?
            jobs.each do |instance_id, jobid|
              server_start = connection.query_async_job_result('jobid'=>jobid)
              if server_start['queryasyncjobresultresponse'].fetch('jobstatus') == 1
                jobs.delete(instance_id)

                puts "\n\n"
                ui.warn("Started server #{instance_id}")
              else
                print "#{ui.color(".", :magenta)}"
                sleep(1)
              end
            end
          end
        end
      end
    end
  end
end
