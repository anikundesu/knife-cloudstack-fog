# Author:: Chirag Jog (<chirag@clogeny.com>)
# Copyright:: Copyright (c) 2011 Clogeny Technologies.
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

        image_list = [
          ui.color('ID', :bold),
          ui.color('Name', :bold),
          ui.color('Size', :bold),
          ui.color('OS Type', :bold),
          ui.color('Location', :bold),
        ]
        
        filter = config['filter']
        puts filter
        response = connection.list_templates['listtemplatesresponse', filter]
        puts response
        
        if templates = response['templates']
          templates.each do |template|
            puts template
          end
          
        template_list = image_list.map do |item|
          item.to_s
        end
        end

        puts ui.list(template_list, :columns_across, 6)
      end
    end
  end
end
