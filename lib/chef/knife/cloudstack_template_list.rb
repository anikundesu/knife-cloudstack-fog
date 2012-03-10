# Author:: Chirag Jog (<chirag@clogeny.com>)
# Copyright:: Copyright (c) 2011 Clogeny Technologies.
# License:: Apache License, Version 2.0
#
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
    class CloudstackTemplateList < Knife

      include Knife::CloudstackBase

      banner "knife cloudstack template list (options)"
      option :filter,
             :short => "-L FILTER",
             :long => "--filter FILTER",
             :description => "The template search filter. Default is 'featured'",
             :default => "featured"

      def run

        validate!

        template_list = [
          ui.color('ID', :bold),
          ui.color('Hypervisor', :bold),
          ui.color('Size (in GB)', :bold),
          ui.color('Zone Location', :bold),
          ui.color('Name', :bold)          
        ]
        
        filter = config['filter']
        settings = connection.list_templates('templatefilter' => 'featured')
        if response = settings['listtemplatesresponse']
          response.each do |templates|
            if templates = response['template']
              templates.each do |template|
                template_list << template['id'].to_s
                template_list << template['hypervisor']

                template_size = template['size']
                template_size = (template_size/1024/1024/1024)
                template_list << template_size.to_s

                template_list << template['zonename']
                template_list << template['name']                
              end
            end
          end
          puts ui.list(template_list, :columns_across, 5)
        end
      end
    end
  end
end
