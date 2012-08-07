#
# Author:: Chirag Jog (<chirag@clogeny.com>), Jeff Moody (<jmoody@datapipe.com>)
# Copyright:: Copyright (c) 2011 Clogeny Technologies, Copyright (c) 2012 Datapipe
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

require 'chef/knife'

class Chef
  class Knife
    module CloudstackBase

      # :nodoc:
      # Would prefer to do this in a rational way, but can't be done b/c of
      # Mixlib::CLI's design :(
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'fog'
            require 'readline'
            require 'chef/json_compat'
          end

          option :cloudstack_access_key_id,
            :short => "-A ID",
            :long => "--cloudstack-access-key-id KEY",
            :description => "Your Cloudstack Access Key ID",
            :proc => Proc.new { |pkey| Chef::Config[:knife][:cloudstack_access_key_id] = pkey }

          option :cloudstack_secret_access_key,
            :short => "-K SECRET",
            :long => "--cloudstack-secret-access-key SECRET",
            :description => "Your Cloudstack API Secret Access Key",
            :proc => Proc.new { |skey| Chef::Config[:knife][:cloudstack_secret_access_key] = skey }

          option :cloudstack_api_endpoint,
            :long => "--cloudstack-api-endpoint ENDPOINT",
            :description => "Your Cloudstack API endpoint",
            :proc => Proc.new { |endpoint| Chef::Config[:knife][:cloudstack_api_endpoint] = endpoint }          
        end
      end

      def connection
        @connection ||= begin
          cloudstack_uri =  URI.parse(Chef::Config[:knife][:cloudstack_api_endpoint])
          connection = Fog::Compute.new(
            :provider => :cloudstack,
            :cloudstack_api_key => Chef::Config[:knife][:cloudstack_access_key_id],
            :cloudstack_secret_access_key => Chef::Config[:knife][:cloudstack_secret_access_key],
            :cloudstack_host => cloudstack_uri.host,
            :cloudstack_port => cloudstack_uri.port,
            :cloudstack_path => cloudstack_uri.path,
            :cloudstack_scheme => cloudstack_uri.scheme
          )
        end
      end

      def locate_config_value(key)
        key = key.to_sym
        Chef::Config[:knife][key] || config[key]
      end

      def msg_pair(label, value, color=:cyan)
        if value && !value.to_s.empty?
          puts "#{ui.color(label, color)}: #{value}"
        end
      end

      def validate!(keys=[:cloudstack_access_key_id, :cloudstack_secret_access_key, :cloudstack_api_endpoint])
        errors = []

        keys.each do |k|
          pretty_key = k.to_s.gsub(/_/, ' ').gsub(/\w+/){ |w| (w =~ /(ssh)|(aws)/i) ? w.upcase  : w.capitalize }
          if Chef::Config[:knife][k].nil?
            errors << "You did not provided a valid '#{pretty_key}' value."
          end
        end

        if errors.each{|e| ui.error(e)}.any?
          exit 1
        end
      end

    end
  end
end


