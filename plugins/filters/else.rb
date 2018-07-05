# Else
# If image exists, print variable otherwise print input.
# {{ image | else:" has-image" }}

module Else

  def else(content, else_content = "")

    content = content.to_s

    if else_content.empty?
      return
    end

    return (content.nil? or content.empty?) ? else_content : ''

  end

end

Liquid::Template.register_filter(Else)