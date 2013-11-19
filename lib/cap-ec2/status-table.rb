require 'aws-sdk'

module CapEC2
  class StatusTable
    
    def initialize(instances)
      @instances = instances
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
        "Stage".bold
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
        instance.tags["Name"].green,
        instance.id.red,
        instance.instance_type.cyan,
        instance.contact_point.blue.bold,
        instance.availability_zone.magenta,
        instance.tags["Role"].yellow,
        instance.tags["Stage"].yellow
      ]
    end
  end
end

