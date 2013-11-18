require 'aws-sdk'
require_relative 'instance'
require 'yaml'
require 'capistrano/configuration'

module CapEC2
  class EC2Handler
    
    def initialize(ec2_config = "config/ec2.yml")
      @ec2_config = YAML.load_file ec2_config
      @ec2 = AWS::EC2.new(
        access_key_id: @ec2_config["access_key_id"],
        secret_access_key: @ec2_config["secret_access_key"],
        region: @ec2_config["region"]
      )
    end
    
    def stage
      Capistrano::Configuration.env.fetch(:stage).to_s
    end
    
    def application
      Capistrano::Configuration.env.fetch(:application).to_s
    end
    
    def get_servers_for_role(role)
      instances = @ec2.instances
        .filter("tag:Project", application)
        .filter("tag:Role", role.to_s)
        .filter("tag:Stage", stage)
        .map {|i| i.contact_point}
    end
    
  end
end