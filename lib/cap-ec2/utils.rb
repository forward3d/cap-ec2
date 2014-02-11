module CapEC2
  module Utils
    def project_tag
      @ec2_config["project_tag"] || "Project"
    end
    
    def roles_tag
      @ec2_config["roles_tag"] || "Roles"
    end
    
    def stages_tag
      @ec2_config["stages_tag"] || "Stages"
    end 
    
    def self.contact_point(instance)
      instance.public_dns_name || instance.public_ip_address || instance.private_ip_address
    end
    
  end
end