# Author:: Chirag Jog (<chirag@clogeny.com>), Jeff Moody (<jmoody@datapipe.com>), dfuentes77
# Copyright:: Copyright (c) 2011 Clogeny Technologies, Copyright (c) 2012 Datapipe
# License:: Apache License, Version 2.0
#
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
    class CloudstackTemplateList < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack template list (options)"
      option  :filter,
              :short => "-L FILTER",
              :long => "--filter FILTER",
              :description => "The template search filter. Default is 'featured.' Other options are 'self,' 'self-executable,' 'executable,' and 'community.'",
              :default => "featured"
      option  :zone,
              :short => "-Z ZONE",
              :long => "--zone ZONE",
              :description => "Limit responses to templates only located in a specific zone. Default provides templates from all zones.",
              :default => "all"
      option  :hypervisor,
              :short => "-H HYPERVISOR",
              :long => "--hypervisor HYPERVISOR",
              :description => "Limit responses to templates only running on a specific hypervisor. Default provides templates from all hypervisors.",
              :default => "all"
      option  :zoneid,
              :short => "-z ZONEID",
              :long => "--zoneid ZONEID",
              :description => "Limit responses to templates only running in a specific zone (specified by ID #). Default provides templates from all zones.",
              :default => "all"
      option  :templateid,
              :short => "-T TEMPLATEID",
              :long => "--templateid TEMPLATEID",
              :description => "Limit responses to a single template ID. Default provides all templates.",
              :default => "all"


      def print_templates(template_list,templates,options={})
        temp = templates

        if templateid = options[:templateid]
          temp.reject!{|t| t['id'] != templateid}
        end
        if zoneid = options[:zoneid]
          temp.reject!{|t| t['zoneid'] != zoneid}
        end
        if zone = options[:zone]
          temp.reject!{|t| t['zonename'] != zone}
        end
        if hypervisor = options[:hypervisor]
          temp.reject!{|t| t['hypervisor'] != hypervisor}
        end

        # Sorting to group by zone ID first, then ID

        sort1 = temp.sort_by { |hsh| hsh["id"] }
        sorted = sort1.sort_by { |hsh| hsh["zoneid"] }

        sorted.each do |template|
          template_list << template['id'].to_s
          template['hypervisor'] = ' ' if template['hypervisor'].nil?
          template_list << template['hypervisor']

          template_size = template['size']
          template_size = (template_size/1024/1024/1024)
          template_list << template_size.to_s

          template_list << template['zonename']
          template_list << template['zoneid'].to_s
          template_list << template['name']
        end
      end

      def run
        validate!

        template_list = [
          ui.color('ID', :bold),
          ui.color('Hypervisor', :bold),
          ui.color('Size (in GB)', :bold),
          ui.color('Zone Name', :bold),
          ui.color('Zone ID', :bold),
          ui.color('Name', :bold)
        ]

        filter = locate_config_value(:filter)
        zone = locate_config_value(:zone)
        zoneid = locate_config_value(:zoneid)
        hypervisor = locate_config_value(:hypervisor)
        templateid = locate_config_value(:templateid)

        settings = connection.list_templates('templatefilter' => filter)
        if response = settings['listtemplatesresponse']
          Chef::Log.debug("Response: #{response}")
          if templates = response['template']
            filters = {}
            filters[:hypervisor] = hypervisor unless hypervisor == 'all'
            filters[:zone] = zone unless zone == 'all'
            filters[:zoneid] = zoneid unless zoneid == 'all'
            filters[:templateid] = templateid unless templateid == 'all'

            print_templates(template_list,templates,filters)
          end
          puts ui.list(template_list, :uneven_columns_across, 6)
        end

      end
    end
  end
end
