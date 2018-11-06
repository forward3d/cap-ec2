require 'capistrano/configuration'
require 'aws-sdk-ec2'
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
        ec2_handler.get_servers_for_role(name).each do |server|
          env.role(name, CapEC2::Utils.contact_point(server),
                   options_with_instance_id(options, server))
        end
      end

      def env
        Configuration.env
      end

      private

      def options_with_instance_id(options, server)
        options.merge({aws_instance_id: server.instance_id})
      end

    end
  end
end

self.extend Capistrano::DSL::Ec2

Capistrano::Configuration::Server.send(:include, CapEC2::Utils::Server)
