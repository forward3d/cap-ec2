require 'capistrano/configuration'
require 'aws-sdk-v1'
require 'colorize'
require 'terminal-table'
require 'yaml'
require_relative 'utils'
require_relative 'ec2-handler'
require_relative 'status-table'

# Load extra tasks
load File.expand_path("../tasks/ec2.rake", __FILE__)

module Capistrano
  module DSL
    module Ec2

      def ec2_handler
        @ec2_handler ||= CapEC2::EC2Handler.new
      end

      def ec2_role(name, options={})
        ec2_handler.get_servers_for_role(options.fetch(:roles, name)).each do |roles, servers|
          servers.each do |server|
            env.role(name, CapEC2::Utils.contact_point(server), options_with_instance_id(options, server, roles))
          end
        end
      end

      def env
        Configuration.env
      end

      private

      def options_with_instance_id(options, server, extra_roles)
        options.merge({aws_instance_id: server.instance_id, extra_roles: Array(extra_roles).map(&:to_sym)})
      end

    end
  end
end

self.extend Capistrano::DSL::Ec2

Capistrano::Configuration::Server.send(:include, CapEC2::Utils::Server)
