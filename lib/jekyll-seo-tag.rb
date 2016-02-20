require 'jekyll-seo-tag/filters'

module Jekyll
  class SeoTag < Liquid::Tag
    attr_accessor :context

    MINIFY_REGEX = /(>\n|[%}]})\s+(<|{[{%])/

    def render(context)
      @context = context
      output = template.render!(payload, info)

      output
    end

    private

    def payload
      {
        'seo_tag' => { 'version' => VERSION, 'author' => author },
        'page'    => page,
        'site'    => site
      }
    end

    def page
      context.registers[:page]
    end

    def site
      context.registers[:site].site_payload['site']
    end

    def info
      {
        registers: context.registers,
        filters: [Jekyll::Filters, JekyllSeoTag::Filters]
      }
    end

    def template
      @template ||= Liquid::Template.parse template_contents
    end

    def template_contents
      @template_contents ||= begin
        File.read(template_path).gsub(MINIFY_REGEX, '\1\2').chomp
      end
    end

    def template_path
      @template_path ||= begin
        File.expand_path './template.html', File.dirname(__FILE__)
      end
    end

    # Returns a hash representing the post author
    #
    # Sources, in order:
    #
    # 1. page.author, if page.author is a hash
    # 2. site.author, if site.author is a hash
    # 3. site.data.authors[page.author] if page.author is a string
    # 4. page.author if page.author is a string
    def author
      author = page['author'] || site['author']
      return if author.nil?
      return author if author.is_a?(Hash)

      if author.is_a?(String)
        if site['data']['authors'] && site['data']['authors'][author]
          site['data']['authors'][author]
        else
          { 'twitter' => author }
        end
      end
    end
  end
end

Liquid::Template.register_tag('seo', Jekyll::SeoTag)
