require 'capistrano/setup'
require 'capistrano/configuration'
require_relative 'ec2-handler'

# Monkey patch into Capistrano v3

module Capistrano
  module TaskEnhancements

    def ec2_handler
      @ec2_handler ||= CapEC2::EC2Handler.new(env.fetch(:ec2_config, "config/ec2.yml"))
    end
    
    def ec2_role(name, options={})
      env.role(name, ec2_handler.get_servers_for_role(name), {})
    end
    
    def env
      Configuration.env
    end
    
  end
end
