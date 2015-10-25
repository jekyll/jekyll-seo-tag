module Jekyll
  class SeoTag < Liquid::Tag

    attr_accessor :context

    def render(context)
      @context = context
      Liquid::Template.parse(template_contents).render!(payload, info).gsub(/[\n\s]{2,}/, "\n")
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
      @template_contents ||= File.read(template_path)
    end

    def template_path
      @template_path ||= File.expand_path "./template.html", File.dirname(__FILE__)
    end
  end
end

Liquid::Template.register_tag('seo', Jekyll::SeoTag)
