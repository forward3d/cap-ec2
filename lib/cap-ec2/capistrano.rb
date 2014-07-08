require 'capistrano/setup'
require 'capistrano/configuration'
require 'aws-sdk'
require 'colored'
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
      include CapEC2::Utils

      def ec2_handler
        @ec2_handler ||= CapEC2::EC2Handler.new
      end

      def ec2_role(name, options={})
        ec2_handler.get_servers_for_role(name).each do |server|
          env.role(name, CapEC2::Utils.contact_point(server), options)
        end
      end

      def ec2_server(options={})
        ec2_handler.get_servers.each do |server|
          roles = server.tags[roles_tag] || ''
          env.server(CapEC2::Utils.contact_point(server), options.merge(roles: roles.split(',')))
        end
      end

      def env
        Configuration.env
      end

    end
  end
end

self.extend Capistrano::DSL::Ec2

