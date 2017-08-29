module CapEC2
  class StatusTable
    include CapEC2::Utils

    def initialize(instances)
      @instances = instances
      output
    end

    def header_row
      [
        bold("Num"),
        bold("Name"),
        bold("ID"),
        bold("Type"),
        bold("DNS"),
        bold("Zone"),
        bold("Roles"),
        bold("Stages")
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
        green(tag_value(instance, 'Name') || ''),
        red(instance.instance_id),
        cyan(instance.instance_type),
        bold(blue(CapEC2::Utils.contact_point(instance))),
        magenta(instance.placement.availability_zone),
        yellow(tag_value(instance, roles_tag)),
        yellow(tag_value(instance, stages_tag))
      ]
    end

  private

    (String.colors + String.modes).each do |format|
      define_method(format) do |string|
        if $stdout.tty?
          string.__send__(format)
        else
          string
        end
      end
    end

  end
end
