module CapEC2
  class EC2Handler
    include CapEC2::Utils

    def initialize
      load_config
      configured_regions = get_regions(fetch(:ec2_region))
      @ec2 = {}
      configured_regions.each do |region|
        @ec2[region] = ec2_connect(region)
      end
    end

    def ec2_connect(region=nil)
      AWS.start_memoizing
      AWS::EC2.new(
        access_key_id: fetch(:ec2_access_key_id),
        secret_access_key: fetch(:ec2_secret_access_key),
        region: region
      )
    end

    def status_table
      CapEC2::StatusTable.new(
        defined_roles.map {|r| get_servers_for_role(r)}.flatten.uniq {|i| i.instance_id}
      )
    end

    def server_names
      puts defined_roles.map {|r| get_servers_for_role(r)}
                   .flatten
                   .uniq {|i| i.instance_id}
                   .map {|i| i.tags["Name"]}
                   .join("\n")
    end

    def instance_ids
      puts defined_roles.map {|r| get_servers_for_role(r)}
                   .flatten
                   .uniq {|i| i.instance_id}
                   .map {|i| i.instance_id}
                   .join("\n")
    end

    def defined_roles
      Capistrano::Configuration.env.send(:servers).send(:available_roles).sort
    end

    def stage
      Capistrano::Configuration.env.fetch(:stage).to_s
    end

    def application
      Capistrano::Configuration.env.fetch(:application).to_s
    end

    def tag(tag_name)
      "tag:#{tag_name}"
    end

    def get_servers_for_role(role)
      servers = []
      @ec2.each do |_, ec2|
        instances = ec2.instances
          .filter(tag(project_tag), "*#{application}*")
          .filter('instance-state-name', 'running')
        servers << instances.select do |i|
          instance_has_tag?(i, roles_tag, role) &&
            instance_has_tag?(i, stages_tag, stage) &&
            instance_has_tag?(i, project_tag, application)
        end
      end
      servers.flatten.sort_by {|s| s.tags["Name"]}
    end

    private

    def instance_has_tag?(instance, key, value)
      instance.tags[key].split(',').map(&:strip).include?(value.to_s)
    end
  end
end
