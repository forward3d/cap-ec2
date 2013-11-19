namespace :ec2 do
  
  task :status do
    ec2_handler.status_table
  end
  
end