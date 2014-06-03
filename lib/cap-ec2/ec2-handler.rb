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
        defined_roles.map {|r| get_servers_for_role(r).values }.flatten.uniq {|i| i.instance_id}
      )
    end

    def server_names
      puts defined_roles.map {|r| get_servers_for_role(r).values }
                   .flatten
                   .uniq {|i| i.instance_id}
                   .map {|i| i.tags["Name"]}
                   .join("\n")
    end

    def instance_ids
      puts defined_roles.map {|r| get_servers_for_role(r).values }
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

    def get_servers_for_role(roles)
      roles = Array(roles).map(&:to_s)
      @ec2.each.with_object({}) do |(_, ec2), out|
        instances = ec2.instances.filter(tag(project_tag), "*#{application}*").filter('instance-state-name', 'running')

        instances.each do |i|
          if instance_has_tag?(i, stages_tag, stage) && instance_has_tag?(i, project_tag, application)
            matching_roles = instance_tags_matching(i, roles_tag, roles).sort
            if matching_roles.any?
              out[matching_roles] ||= []
              out[matching_roles] << i
            end
          end
        end
      end
    end

    private

    def instance_has_tag?(instance, key, values)
      instance_tags_matching(instance, key, values).any?
    end

    def instance_tags_matching(instance, key, values)
      return [] if instance.tags[key].nil?
      instance.tags[key].split(',').map(&:strip) & Array(values)
    end
  end
end
