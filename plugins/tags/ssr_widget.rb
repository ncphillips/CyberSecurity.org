# SSR Widget. Uses Config.yml widget.ssr variable.
# {% ssr_widget %}

require 'net/http'

module Jekyll

  class SSRWidget < Liquid::Tag

    # Initialize
    def initialize(tag_name, widget = '', tokens)

      super
      @widget = !widget.empty? ? widget : ''

    end

    # Render
    def render(context)

      site      = context.registers[:site].config
      domain    = site['url'] ? site['url'].chomp('/') : ''
      page      = context.registers[:page]['url'] != '/index' ? context.registers[:page]['url'].chomp('.html') : '/'
      publisher = site['publisher'] ? '&publisher=' + site['publisher'] : ''
      widget    = !@widget.empty? ? @widget : (site['widget']['ssr'] ? site['widget']['ssr'] : '')

      if publisher.empty? || widget.empty?
        return '<span style="text-align: center; background: #efefef; padding: 15px; display: block;">Missing either <strong>publisher</strong> or <strong>ssr_widget</strong> variable, check projets _config.yml.'
      end

      Net::HTTP.get(URI(widget + publisher + '&url=' + domain + page))

    end

  end

end

Liquid::Template.register_tag('ssr_widget', Jekyll::SSRWidget)