# frozen_string_literal: true

require "erb"

class BaseGenerator
  attr_reader :ucdata, :template_name

  def initialize(ucdata, template_name = nil)
    @ucdata = ucdata
    @template_name = template_name
  end

  def render(name = nil)
    template = File.join(__dir__, "templates", (name || template_name))
    erb = ERB.new(File.read(template), trim_mode: "-")

    erb.result(binding)
  end
  alias to_s render

  private

  def regex_string(values)
    values
      .slice_when { |i, j| i.value + 1 != j.value }
      .each do |slice|
      case slice.size
      when 1
        yield slice.first.to_utf8
      when 2
        yield slice.first.to_utf8 + slice.last.to_utf8
      else
        yield "#{slice.first.to_utf8}-#{slice.last.to_utf8}"
      end
    end
  end
end
