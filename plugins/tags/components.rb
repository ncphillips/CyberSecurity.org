module Jekyll

  #
  # Blocks Class
  # Extends Jekyll Liquid Blocks
  #
  class CustomBlocks < Liquid::Block
    include Liquid::StandardFilters

    # Initialize
    def initialize(tag, markup, tokens)
      @template = Liquid::Template.parse(File.read(Dir.glob('html/components/**/' + tag + '.block').first))
      @markup   = markup
      @tag      = tag
      @Helpers  = TagHelpers.new
      super
    end

    # Render Template with Properties
    def render(context)
      @template.render(@Helpers.getProperties(context, @tag, @markup, super))
    end
  end


  #
  # Tags Class
  # Extends Jekyll Liquid Tags
  #
  class CustomTags < Liquid::Tag
    include Liquid::StandardFilters

    # Intialize
    def initialize(tag, markup, tokens)
      @template = Liquid::Template.parse(File.read(Dir.glob('html/components/**/' + tag + '.tag').first))
      @markup   = markup
      @tag      = tag
      @Helpers  = TagHelpers.new
      super
    end

    # Render Template with Properties
    def render(context)
      @template.render(@Helpers.getProperties(context, @tag, @markup))
    end
  end


  #
  # Tag/Block Helpers Class
  #
  class TagHelpers


    # Get Static/Dynamic Properties
    def getProperties(context, tag, markup, content = "")

      # Properties Attribute
      variables            = Hash.new
      variables['content'] = content;
      variables['site']    = !context['site'].nil? ? context['site'] : context.registers[:site].config;
      variables['page']    = context['page'];
      variables['layout']  = context['layout'];

      # Tag variables from Page, Layout & Config
      tag_config = !variables['site'][tag].nil? ? variables['site'][tag] : Hash.new;
      tag_layout = !variables['layout'][tag].nil? ? variables['layout'][tag] : Hash.new;
      tag_page   = !variables['page'][tag].nil? ? variables['page'][tag] : Hash.new;
      tag_all    = tag_config.merge!(tag_layout).merge!(tag_page)

      if !tag_all.empty?
        tag_all.each do |key, value|
          value = parseValue(value)
          if !value.nil?
            variables[key] = value
          end
        end
      end

      # Variables from Context
      properties = markup.gsub(/\:\"(.*?)\"\s+/, " ").gsub(/\:\'(.*?)\'\s+/, " ").gsub(/\:(.*?)\s+/, " ").to_s
      properties.split(" ").each do |key|
        value = parseValue(value)
        if !value.nil?
          variables[key] = value
        end
      end

      # Variables from Tag
      markup.scan(Liquid::TagAttributes) do |key, value|
        value = parseValue(value)
        if !value.nil?
          variables[key] = value
        end
      end

      # Return Variables
      return variables

    end


    # Parse Variable Value
    def parseValue(data)

      # Remove surrounding quotes & spaces
      value = data.to_s.gsub(/^'|"/, '').gsub(/'|"$/, '').strip

      # If empty, make nil
      if value.empty?
        value = nil;
      end

      # Convert string true to boolean true
      if value == "true" || value == "TRUE"
        value = true
      end

      # Convert string false to boolean false
      if value == "false" || value == "FALSE"
        value = false
      end

      # Convert number to floating or integer
      if is_number?(value)
        if value.include?('.') || value.include?(',')
          value = value.to_f
        else
          value = value.to_i
        end
      end

      # Return Value
      return value

    end


    # Is Number Method
    def is_number? string
      true if Float(string) rescue false
    end


  end

end


# Loop Components Directory For Tags/Blocks
Dir.glob('html/components/**/*') do |file|
  ext = File.extname(file)

  if ext === ".tag" || ext === ".block"
    Liquid::Template.register_tag(File.basename(file, ext), ext === ".tag" ? Jekyll::CustomTags : Jekyll::CustomBlocks)
  end
end