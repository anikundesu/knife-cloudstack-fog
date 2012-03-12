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
    class CloudstackInstanceCreate < Knife
      
      include Knife::CloudstackBase

      deps do
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end
      
      banner "knife cloudstack server create (options)"

      attr_accessor :initial_sleep_delay

      option  :cloudstack_service,
              :short => "-S SERVICEOFFERING",
              :long => "--serviceoffering SERVICEOFFERING",
              :description => "The service offering to use for the server.",
              :proc => Proc.new { |o| Chef::Config[:knife][:serviceoffering] = o }

      option  :cloudstack_template,
              :short => "-T TEMPLATE",
              :long => "--template TEMPLATE",
              :description => "The template for the server.",
              :proc => Proc.new { |t| Chef::Config[:knife][:template] = t }

      option  :cloudstack_zone,
              :short => "-Z ZONEID",
              :long => "--zone ZONEID",
              :description => "The Availability Zone ID ",
              :proc => Proc.new { |z| Chef::Config[:knife][:cloudstack_zone] = z }
        
      option  :cloudstack_networks,
              :short => "-W NETWORKS",
              :long => "--networks NETWORK",
              :description => "Comma separated list of CloudStack network names",
              :proc => lambda { |n| n.split(/[\s,]+/) },
              :default => []
              
      option  :cloudstack_securitygroups,
              :short => "-G SECURITYGROUPS",
              :long => "--securitygroups SECURITYGROUPS",
              :description => "Comma separated list of CloudStack security group names",
              :proc => lambda { |g| g.split(/[\s,]+/) },
              :default => []

      option  :chef_node_name,
              :short => "-N NAME",
              :long => "--node-name NAME",
              :description => "The Chef node name for your new node",
              :proc => Proc.new { |key| Chef::Config[:knife][:chef_node_name] = key }

      option  :ssh_user,
              :short => "-x USERNAME",
              :long => "--ssh-user USERNAME",
              :description => "The ssh username"

      option  :ssh_password,
              :short => "-P PASSWORD",
              :long => "--ssh-password PASSWORD",
              :description => "The ssh password"

      option  :identity_file,
              :short => "-i IDENTITY_FILE",
              :long => "--identity-file IDENTITY_FILE",
              :description => "The SSH identity file used for authentication"

      option  :prerelease,
              :long => "--prerelease",
              :description => "Install the pre-release chef gems",
              :proc => Proc.new { |key| Chef::Config[:knife][:prerelease] = key }

      option  :bootstrap_version,
              :long => "--bootstrap-version VERSION",
              :description => "The version of Chef to install",
              :proc => Proc.new { |v| Chef::Config[:knife][:bootstrap_version] = v },
              :default => "0.10.4"

      option  :distro,
              :short => "-d DISTRO",
              :long => "--distro DISTRO",
              :description => "Bootstrap a distro using a template; default is 'ubuntu10.04-gems'",
              :proc => Proc.new { |d| Chef::Config[:knife][:distro] = d },
              :default => "ubuntu10.04-gems"

      option  :template_file,
              :long => "--template-file TEMPLATE",
              :description => "Full path to location of template to use",
              :proc => Proc.new { |t| Chef::Config[:knife][:template_file] = t },
              :default => false

      option  :run_list,
              :short => "-r RUN_LIST",
              :long => "--run-list RUN_LIST",
              :description => "Comma separated list of roles/recipes to apply",
              :proc => lambda { |o| o.split(/[\s,]+/) },
              :default => []


      def tcp_test_ssh(hostname)
        tcp_socket = TCPSocket.new(hostname, 22)
        readable = IO.select([tcp_socket], nil, nil, 5)
        if readable
          Chef::Log.debug("sshd accepting connections on #{hostname}, banner is #{tcp_socket.gets}")
          yield
          true
        else
          false
        end
        rescue Errno::ETIMEDOUT
          false
        rescue Errno::EPERM
          false
        rescue Errno::ECONNREFUSED
          sleep 2
          false
        rescue Errno::EHOSTUNREACH
          sleep 2
          false
        ensure
          tcp_socket && tcp_socket.close
      end
      
      def validate_options

        unless locate_config_value :cloudstack_template
          ui.error "Cloudstack template not specified"
          exit 1
        end

        unless locate_config_value :cloudstack_service
          ui.error "Cloudstack service offering not specified"
          exit 1
        end

        identity_file = locate_config_value :identity_file
        ssh_user = locate_config_value :ssh_user
        ssh_password = locate_config_value :ssh_password
        unless identity_file || (ssh_user && ssh_password)
          ui.error("You must specify either an ssh identity file or an ssh user and password")
          exit 1
        end
      end

      def bootstrap_for_node(host)
        bootstrap = Chef::Knife::Bootstrap.new
        bootstrap.name_args = [host]
        bootstrap.config[:run_list] = config[:run_list]
        bootstrap.config[:ssh_user] = config[:ssh_user]
        bootstrap.config[:ssh_password] = config[:ssh_password]
        bootstrap.config[:identity_file] = config[:identity_file]
        bootstrap.config[:chef_node_name] = config[:chef_node_name] if config[:chef_node_name]
        bootstrap.config[:prerelease] = config[:prerelease]
        bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
        bootstrap.config[:distro] = locate_config_value(:distro)
        bootstrap.config[:use_sudo] = true
        bootstrap.config[:template_file] = locate_config_value(:template_file)
        bootstrap.config[:environment] = config[:environment]
        # may be needed for vpc_mode
        bootstrap.config[:no_host_key_verify] = config[:no_host_key_verify]
        bootstrap
      end

      def locate_config_value(key)
        key = key.to_sym
        Chef::Config[:knife][key] || config[key]
      end
      
      
      def run
        # validate hostname and options
        hostname = @name_args.first
        unless /^[a-zA-Z0-9][a-zA-Z0-9-]*$/.match hostname then
          ui.error "Invalid hostname. Please specify a short hostname, not an fqdn (e.g. 'myhost' instead of 'myhost.domain.com')."
          exit 1
        end
        validate_options

        $stdout.sync = true
        print "#{ui.color("Waiting for server", :magenta)}"
        options = {}
        options[:hostname] = hostname
        options[:template] = locate_config_value(:cloudstack_template).to_i
        options[:zone] = locate_config_value(:cloudstack_zone).to_i
        options[:service] = locate_config_value(:cloudstack_service).to_i
        if (:cloudstack_securitygroups.nil?)
          options[:networkids] = locate_config_value(:cloudstack_networks)
        else
          options[:securitygroupids] = locate_config_value(:cloudstack_securitygroups)
        end
        
        puts options
        puts connection.deploy_virtual_machine('deployVirtualMachine' => options)
        server = connection.deploy_virtual_machine(options)
        
        public_ip = find_or_create_public_ip(server, connection)

        puts "\n\n"
        puts "#{ui.color("Name", :cyan)}: #{server['name']}"
        puts "#{ui.color("Public IP", :cyan)}: #{public_ip}"

        return if config[:no_bootstrap]

        print "\n#{ui.color("Waiting for sshd", :magenta)}"

        print(".") until is_ssh_open?(public_ip) {
          sleep BOOTSTRAP_DELAY
          puts "\n"
        }

        bootstrap_for_node(public_ip).run

        puts "\n"
        puts "#{ui.color("Name", :cyan)}: #{server['name']}"
        puts "#{ui.color("Public IP", :cyan)}: #{public_ip}"
        puts "#{ui.color("Environment", :cyan)}: #{config[:environment] || '_default'}"
        puts "#{ui.color("Run List", :cyan)}: #{config[:run_list].join(', ')}"
        
      end
      
    end
  end
end