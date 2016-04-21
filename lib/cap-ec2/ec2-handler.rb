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
      roles(:all).flat_map(&:roles_array).uniq.sort
    end

    def stage
      Capistrano::Configuration.env.fetch(:stage).to_s
    end

    def application
      Capistrano::Configuration.env.fetch(:application).to_s
    end

    def filter
      f = Capistrano::Configuration.env.fetch(:ec2_filter)
      f.respond_to?(:call) ? f.call : f
    end

    def default_filter
      { tag(project_tag) => "*#{application}*" }
    end

    def tag(tag_name)
      "tag:#{tag_name}"
    end

    def get_servers_for_filter(filter)
      @ec2.flat_map do |_, ec2|
        instances = ec2.instances.filter('instance-state-name', 'running')
        filter.each {|key, val| instances = instances.filter(key.to_s, *Array(val).map(&:to_s)) }
        instances.to_a
      end
    end

    def get_servers_for_role(role)
      servers = get_servers_for_filter(filter || default_filter).
                  sort_by {|s| s.tags["Name"] || ''}.select do |i|
                    instance_has_tag?(i, roles_tag, role) &&
                      (filter ||
                        instance_has_tag?(i, stages_tag, stage) &&
                        instance_has_tag?(i, project_tag, application)
                      )
                  end
      if fetch(:ec2_filter_by_status_ok?)
        servers.select {|server| instance_status_ok? server }
      else
        servers
      end
    end

    def get_server(instance_id)
      @ec2.reduce([]) do |acc, (_, ec2)|
        acc << ec2.instances[instance_id]
      end.flatten.first
    end

    private

    def instance_has_tag?(instance, key, value)
      (instance.tags[key] || '').split(',').map(&:strip).include?(value.to_s)
    end

    def instance_status_ok?(instance)
      @ec2.any? do |_, ec2|
        response = ec2.client.describe_instance_status(
          instance_ids: [instance.id],
          filters: [{ name: 'instance-status.status', values: %w(ok) }]
        )
        response.data.has_key?(:instance_status_set) && response.data[:instance_status_set].any?
      end
    end
  end
end
