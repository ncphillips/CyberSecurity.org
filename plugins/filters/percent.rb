# Percent
# Convert string int percentage
# {{ title | percent }}

module Percent

  def percent(input)

    input = input.to_s

    if (input.nil? or input.empty?)
      return
    end

    return input + '%'

  end

end

Liquid::Template.register_filter(Percent)