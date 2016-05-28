require 'jekyll-seo-tag/filters'
require 'jekyll-seo-tag/version'

module Jekyll
  class SeoTag < Liquid::Tag
    attr_accessor :context

    MINIFY_REGEX = /([>,]\n|[%}]})\s+?(<|{[{%]|[ ]+\")/

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
        'version' => Jekyll::SeoTag::VERSION,
        'title'   => title?
      }
    end

    def payload
      {
        'page'    => context.registers[:page],
        'site'    => context.registers[:site].site_payload['site'],
        'paginator' => context['paginator'],
        'seo_tag' => options
      }
    end

    def title?
      !(@text =~ /title=false/i)
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
  end
end

Liquid::Template.register_tag('seo', Jekyll::SeoTag)
