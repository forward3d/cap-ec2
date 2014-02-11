namespace :ec2 do
  
  desc "Show all information about EC2 instances that match this project"
  task :status do
    ec2_handler.status_table
  end
  
  desc "Show EC2 server names that match this project"
  task :server_names do
    ec2_handler.server_names
  end
  
  desc "Show EC2 instance IDs that match this project"
  task :instance_ids do
    ec2_handler.instance_ids
  end
  
end


namespace :load do
  task :defaults do

    set :ec2_project_tag, 'Project'
    set :ec2_roles_tag, 'Roles'
    set :ec2_stages_tag, 'Stages'

  end
end
