module CapEC2
  class StatusTable
    include CapEC2::Utils
    
    def initialize(instances, ec2_config)
      @instances = instances
      @ec2_config = ec2_config
      output
    end
    
    def header_row
      [
        "Num".bold,
        "Name".bold,
        "ID".bold,
        "Type".bold,
        "DNS".bold,
        "Zone".bold,
        "Roles".bold,
        "Stages".bold
      ]
    end
    
    def output
      table = Terminal::Table.new(
        :style => {
          :border_x => "",
          :border_i => "",
          :border_y => ""
        }
      )
      table.add_row header_row
      @instances.each_with_index do |instance,index|
        table.add_row instance_to_row(instance, index)
      end
      puts table.to_s
    end

    def instance_to_row(instance, index)
      [
        sprintf("%02d:", index),
        (instance.tags["Name"] || '').green,
        instance.id.red,
        instance.instance_type.cyan,
        instance.contact_point.blue.bold,
        instance.availability_zone.magenta,
        instance.tags[roles_tag].yellow,
        instance.tags[stages_tag].yellow
      ]
    end
  end
end

