module Jekyll
  class SeoTag < Liquid::Tag

    attr_accessor :context

    HTML_ESCAPE = {
      "\u201c".freeze => '&ldquo;'.freeze,
      "\u201d".freeze => '&rdquo;'.freeze
    }
    HTML_ESCAPE_REGEX = Regexp.union(HTML_ESCAPE.keys).freeze

    def render(context)
      @context = context
      output = Liquid::Template.parse(template_contents).render!(payload, info)

      # Encode smart quotes. See https://github.com/benbalter/jekyll-seo-tag/pull/6
      output.gsub!(HTML_ESCAPE_REGEX, HTML_ESCAPE)

      output
    end

    private

    def payload
      {
        "page" => context.registers[:page],
        "site" => context.registers[:site].site_payload["site"]
      }
    end

    def info
      {
        :registers => context.registers,
        :filters   => [Jekyll::Filters]
      }
    end

    def template_contents
      @template_contents ||= File.read(template_path).gsub(/(>\n|[%}]})\s+(<|{[{%])/,'\1\2').chomp
    end

    def template_path
      @template_path ||= File.expand_path "./template.html", File.dirname(__FILE__)
    end
  end
end

Liquid::Template.register_tag('seo', Jekyll::SeoTag)
