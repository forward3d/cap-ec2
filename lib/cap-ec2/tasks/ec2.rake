namespace :ec2 do
  
  desc "Show EC2 instances that match this project"
  task :status do
    ec2_handler.status_table
  end
  
end