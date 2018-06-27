module Jekyll

  class Styleguide < Liquid::Tag

    Syntax = /(#{Liquid::QuotedFragment}+)?/

    # Escape HTML
    def escapeHTML(string)

      return string.gsub('&', '&amp;').gsub('%}', '&percnt;&rbrace;').gsub('{%', '&lbrace;&percnt;').gsub('>', '&gt;').gsub('<', '&lt;').gsub('"', '&quot;').gsub("'", '&apos;')

    end

    # Escape HTML
    def newLines(string)

      return string.gsub('&percnt;&rbrace;&lbrace;&percnt;', '&percnt;&rbrace;<br />&lbrace;&percnt;').gsub('&gt;&lt;', '&gt;<br />&lt;').gsub('&gt;&lbrace;&percnt;', '&gt;<br />&lbrace;&percnt;').gsub('&percnt;&rbrace;&lt;', '&percnt;&rbrace;<br />&lt;')

    end

    # Get Markup
    def getMarkup(component)

      # Bail if no title
      if component['markup'].nil? or component['title'].nil? or component['title'].empty?
        return;
      end

      # Container
      html = '<div class="' + component['ext'].gsub('.', '') + '-' + component['base'] + '">'

      # Title
      html += '<h3 id="' + component['base'] + '">' + component['title'] + '<a href="#' + component['base'] + '"><sup>&#9875;</sup></a></h3>'

      # Examples
      if !component['example'].nil? or !component['example_1'].nil?

        html += '<h5>Example</h5>'
        html += '<div class="example">'
        i = 0

        loop do
          example = (i === 0) ? 'example' : 'example_' + i.to_s

          i += 1
          if component[example].nil? or i == 6
            break
          end

          html += (component['ext'] === ".snippet") ? component[example] : component[example].gsub('this', component['base'])
          component.delete(example)
        end

        html += '</div>'

      end

      # Markup
      if !component['markup'].nil?
        markup = component['ext'] === ".snippet" ? escapeHTML(component['markup']) : newLines(escapeHTML(component['markup'].gsub('this', component['base'])))

        html += '<h5>Markup</h5><code><pre class="code">' + markup + '<button class="clipboard js-clipboard">Copy</button></pre></code>'
        html += '<div class="clipboard-area"><textarea>' + markup.gsub('<br />', '&#13;') + '</textarea></div>'
      end

      # Additional Properties
      component.each do |property, value|

        if ['base', 'title', 'markup', 'example'].include? property
          next
        end

        case property
        when "ext"
          html += '<h5>Type</h5>' + value.slice(1..-1).capitalize
        else
          html += '<h5>' + property.capitalize + '</h5>' + value
        end

      end

      html += '</div>'

      return html

    end

    # Get Shortcodes HTML
    def getShortcodesHTML()

      html       = ''
      components = Dir.glob('html/components/**/*').sort;

      if components.nil? or components.empty?
        return html
      end

      # Shortcodes Glob Loop
      components.each do |file|
        component         = Hash.new
        component['ext']  = File.extname(file);
        component['base'] = File.basename(file, component['ext']);

        if File.directory?(file)
          html += '<h2 id="' + component['base'] + '">' + component['base'].capitalize + '<a href="#' + component['base'] + '"><sup>&#9875;</sup></a></h2>'
          next
        end

        markup = File.read(file);

        if markup =~ Syntax
          if component['ext'] === ".snippet"
            snippet             = markup.split('{% endcomment %}')[-1].gsub /^$\n/, '';
            component['markup'] = snippet.to_s
          end

          markup.scan(/\{% comment %\}(.*?)\{% endcomment %\}/m).each do |comment|
            comment = (!comment.first.nil? and !comment.first.empty?) ? comment.first : nil;

            if comment.nil?
              next
            end

            comment.each_line do |line|
              property, value = line.split(": ", 2)

              if property.nil? or value.nil?
                next
              end

              property            = property.gsub("\r", ' ').gsub("\n", ' ').squeeze(' ').strip.downcase.to_s
              value               = value.gsub("\r", ' ').gsub("\n", ' ').squeeze(' ').strip.to_s
              component[property] = value;

            end # comment each end

          end # markup each end

          if !component.nil? and component.is_a?(Hash)
            html += getMarkup(component).to_s
          end

        end # markup syntax end

      end # glob end

      return html

    end

    # Render
    def render(context)

      Liquid::Template.parse(getShortcodesHTML()).render(context);

    end

  end

end

Liquid::Template.register_tag('styleguide', Jekyll::Styleguide)