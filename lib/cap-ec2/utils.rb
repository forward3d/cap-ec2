module CapEC2
  module Utils
    def project_tag
      fetch(:ec2_project_tag)
    end
    
    def roles_tag
      fetch(:ec2_roles_tag)
    end
    
    def stages_tag
      fetch(:ec2_stages_tag)
    end 
    
    def self.contact_point(instance)
      instance.public_dns_name || instance.public_ip_address || instance.private_ip_address
    end
    
    def load_config
      config_location = File.expand_path(fetch(:ec2_config), Dir.pwd) if fetch(:ec2_config)
      if config_location && File.exists?(config_location)
        config = YAML.load_file fetch(:ec2_config)
        if config
          set :ec2_project_tag, config['project_tag'] if config['project_tag']
          set :ec2_roles_tag, config['roles_tag'] if config['roles_tag']
          set :ec2_stages_tag, config['stages_tag'] if config['stages_tag']
    
          set :ec2_access_key_id, config['access_key_id'] if config['access_key_id']
          set :ec2_secret_access_key, config['secret_access_key'] if config['secret_access_key']
          set :ec2_region, config['regions'] if config['regions']
        end
      end
    end
    
    def get_regions(regions_array=nil)
      unless regions_array.empty?
        return regions_array
      else
        @ec2 = ec2_connect
        @ec2.regions.map(&:name)
      end
    end
    
  end
end