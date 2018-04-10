require 'aws-sdk-ec2'

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
      Aws::EC2::Client.new(
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
                   .map {|i| tag_value(i, 'Name')}
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

    def tag(tag_name)
      "tag:#{tag_name}"
    end

    def get_servers_for_role(role)
      filters = [
        {name: 'tag-key', values: [stages_tag, project_tag]},
        {name: tag(project_tag), values: ["*#{application}*"]},
        {name: 'instance-state-name', values: %w(running)}
      ]

      servers = []
      @ec2.each do |_, ec2|
        ec2.describe_instances(filters: filters).reservations.each do |r|
          servers += r.instances.select do |i|
              instance_has_tag?(i, roles_tag, role) &&
                instance_has_tag?(i, stages_tag, stage) &&
                instance_has_tag?(i, project_tag, application) &&
                (fetch(:ec2_filter_by_status_ok?) ? instance_status_ok?(i) : true)
          end
        end
      end

      servers.sort_by { |s| tag_value(s, 'Name') || '' }
    end

    def get_server(instance_id)
      @ec2.reduce([]) do |acc, (_, ec2)|
        acc << ec2.instances[instance_id]
      end.flatten.first
    end

    private

    def instance_has_tag?(instance, key, value)
      (tag_value(instance, key) || '').split(tag_delimiter).map(&:strip).include?(value.to_s)
    end

    def instance_status_ok?(instance)
      @ec2.any? do |_, ec2|
        ec2.describe_instance_status(
          instance_ids: [instance.instance_id],
          filters: [{ name: 'instance-status.status', values: %w(ok) }]
        ).instance_statuses.length == 1
      end
    end
  end
end
