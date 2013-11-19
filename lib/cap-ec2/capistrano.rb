require 'capistrano/setup'
require 'capistrano/configuration'
require_relative 'ec2-handler'
require_relative 'status-table'

# Load extra tasks
load File.expand_path("../tasks/ec2.rake", __FILE__)

# Monkey patch into Capistrano v3

module Capistrano
  module TaskEnhancements

    def ec2_handler
      @ec2_handler ||= CapEC2::EC2Handler.new(env.fetch(:ec2_config, "config/ec2.yml"))
    end
    
    def ec2_role(name, options={})
      ec2_handler.get_servers_for_role(name).each do |server|
        env.role(name, server, options)
      end
    end
    
    def env
      Configuration.env
    end
    
  end
end
