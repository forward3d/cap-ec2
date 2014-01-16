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
  end
end