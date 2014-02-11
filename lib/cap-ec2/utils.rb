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
    
  end
end