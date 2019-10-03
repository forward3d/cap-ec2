require 'aws-sdk-ec2'

module CapEC2
  module Utils

    module Server
      def ec2_tags
        id = self.properties.fetch(:aws_instance_id)
        ec2_handler.get_server(id).tags
      end
    end

    def project_tag
      fetch(:ec2_project_tag)
    end

    def roles_tag
      fetch(:ec2_roles_tag)
    end

    def stages_tag
      fetch(:ec2_stages_tag)
    end

    def tag_delimiter
      fetch(:ec2_tag_delimiter)
    end

    def tag_value(instance, key)
      instance.tags.find(-> { {} }) { |t| t[:key] == key.to_s }[:value]
    end

    def self.contact_point_mapping
      {
        :public_dns => :public_dns_name,
        :public_ip => :public_ip_address,
        :private_ip => :private_ip_address
      }
    end

    def self.contact_point(instance)
      ec2_interface = contact_point_mapping[fetch(:ec2_contact_point)]
      return instance.send(ec2_interface) if ec2_interface

      instance.public_dns_name || instance.public_ip_address || instance.private_ip_address
    end

    def load_config
      if fetch(:ec2_profile)
        credentials = Aws::SharedCredentials.new(profile_name: fetch(:ec2_profile)).credentials
        if credentials
          set :ec2_access_key_id, credentials.access_key_id
          set :ec2_secret_access_key, credentials.secret_access_key
        end
      end

      config_location = File.expand_path(fetch(:ec2_config), Dir.pwd) if fetch(:ec2_config)
      if config_location && File.exists?(config_location)
        config = YAML.load(ERB.new(File.read(fetch(:ec2_config))))
        if config
          set :ec2_project_tag, config['project_tag'] if config['project_tag']
          set :ec2_roles_tag, config['roles_tag'] if config['roles_tag']
          set :ec2_stages_tag, config['stages_tag'] if config['stages_tag']
          set :ec2_tag_delimiter, config['tag_delimiter'] if config['tag_delimiter']

          set :ec2_access_key_id, config['access_key_id'] if config['access_key_id']
          set :ec2_secret_access_key, config['secret_access_key'] if config['secret_access_key']
          set :ec2_region, config['regions'] if config['regions']

          set :ec2_filter_by_status_ok?, config['filter_by_status_ok?'] if config['filter_by_status_ok?']
        end
      end
    end

    def get_regions(regions_array=nil)
      unless regions_array.nil? || regions_array.empty?
        return regions_array
      else
        fail "You must specify at least one EC2 region."
      end
    end

  end
end
