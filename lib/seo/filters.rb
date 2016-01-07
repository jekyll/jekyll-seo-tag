class Kramdown::Parser::SmartyPants < Kramdown::Parser::Kramdown
  def initialize(source, options)
    super
    @block_parsers = []
    @span_parsers =  [:smart_quotes, :html_entity, :typographic_syms, :escaped_chars]
  end
end

module Jekyll
  module Seo
    module Filters
      MARKDOWN_OPTIONS = {
        :entity_output => :symbolic,
        :input => :SmartyPants
      }

      def smartify(input)
        Kramdown::Document.new(input, MARKDOWN_OPTIONS).to_html.chomp
      end
    end
  end
end
