require 'aws-sdk'
require_relative 'instance'
require 'yaml'
require 'capistrano/configuration'
require 'terminal-table'
require 'colored'

module CapEC2
  class EC2Handler
    
    def initialize(ec2_config = "config/ec2.yml")
      @ec2_config = YAML.load_file ec2_config
      @ec2 = {}
      @ec2_config["regions"].each do |region|
        @ec2[region] = AWS::EC2.new(
        access_key_id: @ec2_config["access_key_id"],
        secret_access_key: @ec2_config["secret_access_key"],
        region: region
      )
      end
    end
    
    def status_table
      CapEC2::StatusTable.new(get_instances_for_project)
    end
    
    def stage
      Capistrano::Configuration.env.fetch(:stage).to_s
    end
    
    def application
      Capistrano::Configuration.env.fetch(:application).to_s
    end
    
    def project
      Capistrano::Configuration.env.fetch(:project).to_s
    end
    
    def get_servers_for_role(role)
      servers = []
      each_region do |ec2|
        instances = ec2.instances
          .filter("tag:Project", application)
          .filter("tag:Stage", stage)
        servers << instances.select {|i| i.tags["Role"] =~ /,{0,1}#{role}(,|$)/}
                            .map {|i| i.contact_point}
      end
      servers.flatten
    end
    
    def get_instances_for_project
      servers = []
      each_region do |ec2|
        servers << ec2.instances.filter("tag:Project", application).map {|i| i}
      end
      servers.flatten
    end
    
    def each_region
      @ec2.keys.each do |region|
        yield @ec2[region]
      end
    end
    
  end
end