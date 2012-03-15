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

require 'chef/knife/bootstrap'
Chef::Knife::Bootstrap.load_deps
require 'socket'
require 'net/ssh/multi'
require 'chef/json_compat'
require 'chef/knife/cloudstack_base'

class Chef
  class Knife
    class CloudstackInstanceCreate < Knife
      
      include Knife::CloudstackBase
      
      banner "knife cloudstack server create (options)"
      
      option  :cloudstack_serviceid,
              :short => "-s SERVICEID",
              :long => "--serviceid SERVICEID",
              :description => "The CloudStack service offering ID."

      option  :cloudstack_templateid,
              :short => "-t TEMPLATEID",
              :long => "--templateid TEMPLATEID",
              :description => "The CloudStack template ID for the server."

      option  :cloudstack_zoneid,
              :short => "-z ZONEID",
              :long => "--zoneid ZONE",
              :description => "The CloudStack zone ID for the server."

      option  :cloudstack_networknames,
              :short => "-W NETWORKNAMES",
              :long => "--networknames NETWORKNAMES",
              :description => "Comma separated list of CloudStack network names. Each group name must be encapuslated in quotes if it contains whitespace.",
              :proc => lambda { |n| n.split(/[\s,]+/) },
              :default => []

      option  :cloudstack_networkids,
              :short => "-w NETWORKIDS",
              :long => "--networkids NETWORKIDS",
              :description => "Comma separated list of CloudStack network IDs.",
              :proc => lambda { |n| n.split(/[\s,]+/) },
              :default => []

      option  :cloudstack_groupids,
              :short => "-g SECURITYGROUPIDS",
              :long => "--groupids SECURITYGROUPIDS",
              :description => "Comma separated list of CloudStack Security Group IDs.",
              :proc => lambda { |n| n.split(/[\s,]+/) },
              :default => []

      option  :cloudstack_groupnames,
              :short => "-G SECURITYGROUPNAMES",
              :long => "--groupnames SECURITYGROUPNAMES",
              :description => "Comma separated list of CloudStack Security Group names. Each group name must be encapuslated in quotes if it contains whitespace.",
              :proc => lambda { |n| n.split(/[\s,]+/) },
              :default => []

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

      option  :ssh_user,
              :short => "-x USERNAME",
              :long => "--ssh-user USERNAME",
              :description => "The ssh username",
              :default => 'root'

      option  :ssh_password,
              :short => "-P PASSWORD",
              :long => "--ssh-password PASSWORD",
              :description => "The ssh password"
              
      option  :server_name,
              :short => "-N NAME",
              :long => "--server-name NAME",
              :description => "The server name"
        
      def bootstrap_for_node(host, user, password)
        Chef::Log.debug("Bootstrap host: #{host}")
        Chef::Log.debug("Bootstrap user: #{user}")
        Chef::Log.debug("Bootstrap pass: #{password}")
        bootstrap = Chef::Knife::Bootstrap.new
        bootstrap.name_args = host
        bootstrap.config[:run_list] = config[:run_list]
        bootstrap.config[:ssh_user] = user
        bootstrap.config[:ssh_password] = password
        bootstrap.config[:identity_file] = config[:identity_file]
        bootstrap.config[:chef_node_name] = config[:server_name] if config[:server_name]
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
      
      def tcp_test_ssh(hostname)
        tcp_socket = TCPSocket.new(hostname, 22)
        readable = IO.select([tcp_socket], nil, nil, 5)
        if readable
          Chef::Log.debug("\nsshd accepting connections on #{hostname}, banner is #{tcp_socket.gets}\n")
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

      def run
        $stdout.sync = true
        
        options = {}

        options['zoneid'] = locate_config_value(:cloudstack_zoneid)
        options['templateid'] = locate_config_value(:cloudstack_templateid)

        if locate_config_value(:cloudstack_serviceid) != nil
          options['serviceofferingid'] = locate_config_value(:cloudstack_serviceid)
        end
        
        if locate_config_value(:server_name) != nil
          options['displayname'] = locate_config_value(:server_name)
        end
        
        security_groups = []
        if locate_config_value(:cloudstack_groupids) != []
          cs_groupids = locate_config_value(:cloudstack_groupids)
          cs_groupids.each do |id|
            security_groups.push(id)
          end
          options['securitygroupids'] = security_groups
        else
          cs_groupnames = locate_config_value(:cloudstack_groupnames)
          cs_groupnames.each do |name|
            security_groups.push(name)
          end
          options['securitygroupnames'] = security_groups
        end
        
        Chef::Log.debug("Options: #{options} \n")

        server = connection.deploy_virtual_machine(options)
        jobid = server['deployvirtualmachineresponse'].fetch('jobid')

        server_start = connection.query_async_job_result('jobid'=>jobid)
        print "#{ui.color("Waiting for server", :magenta)}"
        while server_start['queryasyncjobresultresponse'].fetch('jobstatus') != 1
          print "#{ui.color(".", :magenta)}"
          sleep(1)
          server_start = connection.query_async_job_result('jobid'=>jobid)
        end
        puts "\n\n"

        Chef::Log.debug("Job ID: #{jobid} \n")
        Chef::Log.debug("Options: #{options} \n")
        server_start = connection.query_async_job_result('jobid'=>jobid)
        Chef::Log.debug("Server_Start: #{server_start} \n")
        
        server_info = server_start['queryasyncjobresultresponse']['jobresult']['virtualmachine']
        
        server_name = server_info['displayname']
        server_id = server_info['hostname']
        server_serviceoffering = server_info['serviceofferingname']
        server_template = server_info['templatename']
        if server_info['password'] != nil
          ssh_password = server_info['password']
        else
          ssh_password = locate_config_value(:ssh_password)
        end
        
        ssh_user = locate_config_value(:ssh_user)
        
        public_ip = nil
        
        if server_info['nic'].size > 0
          public_ip = server_info['nic'].first['ipaddress']
        end
        
        puts "\n\n"
        puts "#{ui.color("Name", :cyan)}: #{server_name}"
        puts "#{ui.color("Public IP", :cyan)}: #{public_ip}"
        puts "#{ui.color("Username", :cyan)}: #{ssh_user}"
        puts "#{ui.color("Password", :cyan)}: #{ssh_password}"
        
        print "\n#{ui.color("Waiting for sshd", :magenta)}"
        
        print("#{ui.color(".", :magenta)}") until tcp_test_ssh(public_ip) { sleep @initial_sleep_delay ||= 10; puts("done") }
        
        bootstrap_for_node(public_ip, ssh_user, ssh_password).run
        
        puts "\n"
        puts "#{ui.color("Instance Name", :green)}: #{server_name}"
        puts "#{ui.color("Instance ID", :green)}: #{server_id}"
        puts "#{ui.color("Service Offering", :green)}: #{server_serviceoffering}"
        puts "#{ui.color("Template", :green)}: #{server_template}"
        puts "#{ui.color("Public IP Address", :green)}: #{public_ip}"
        puts "#{ui.color("User", :green)}: #{ssh_user}"
        puts "#{ui.color("Password", :green)}: #{ssh_password}"
        puts "#{ui.color("Environment", :green)}: #{config[:environment] || '_default'}"
        puts "#{ui.color("Run List", :green)}: #{config[:run_list].join(', ')}" 
 
 
      end
      
    end
  end
end