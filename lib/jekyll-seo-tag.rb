require "jekyll-seo-tag/version"

module Jekyll
  class SeoTag < Liquid::Tag
    attr_accessor :context

    # Matches all whitespace that follows either
    #   1. A '}', which closes a Liquid tag
    #   2. A '{', which opens a JSON block
    #   3. A '>' followed by a newline, which closes an XML tag or
    #   4. A ',' followed by a newline, which ends a JSON line
    # We will strip all of this whitespace to minify the template
    # We will not strip any whitespace if the next character is a '-'
    #   so that we do not interfere with the HTML comment at the
    #   very begining
    MINIFY_REGEX = %r!(?<=[{}]|[>,]\n)\s+(?\!-)!

    def initialize(_tag_name, text, _tokens)
      super
      @text = text
    end

    def render(context)
      @context = context
      template.render!(payload, info)
    end

    private

    def options
      {
        "version" => Jekyll::SeoTag::VERSION,
        "title"   => title?
      }
    end

    def payload
      {
        "page"      => context.registers[:page],
        "site"      => context.registers[:site].site_payload["site"],
        "paginator" => context["paginator"],
        "seo_tag"   => options
      }
    end

    def title?
      !(@text =~ %r!title=false!i)
    end

    def info
      {
        :registers => context.registers,
        :filters   => [Jekyll::Filters]
      }
    end

    def template
      @template ||= Liquid::Template.parse template_contents
    end

    def template_contents
      @template_contents ||= begin
        File.read(template_path).gsub(MINIFY_REGEX, "")
      end
    end

    def template_path
      @template_path ||= begin
        File.expand_path "./template.html", File.dirname(__FILE__)
      end
    end
  end
end

Liquid::Template.register_tag("seo", Jekyll::SeoTag)
