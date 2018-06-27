# Body classes
# {% body_class additional_class_1 additional_class_2 %}

module Jekyll

  class BodyClass < Liquid::Tag

    # Intialize
    def initialize(tag_name, classes = '', tokens)

      super
      @classes = !classes.empty? ? classes.to_s.strip + ' ' : ''

    end

    # Render
    def render(context)

      page = context.registers[:page]

      @classes += page['collection'].to_s + '-collection '
      @classes += page['slug'] ? page['slug'].to_s + '-page ' : ''
      @classes += page['subnav'] ? 'has-sub ' : ''
      @classes += page['body_class'] ? page['body_class'].to_s + ' ' : ''
      @classes += page['layout'] ? page['layout'].to_s + '-template ' : ''

      if !@classes.empty?
        'class="' + @classes.strip + '"'
      end

    end

  end

end

Liquid::Template.register_tag('body_class', Jekyll::BodyClass)