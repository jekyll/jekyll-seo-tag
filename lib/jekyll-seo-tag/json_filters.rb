# frozen_string_literal: true

module Jekyll
  class SeoTag
    # Liquid filters used by the SEO tag template
    module JSONFilters
      # Characters which could end a <script> element or start an HTML comment
      # within it, plus the line terminators which are invalid in JavaScript
      # strings. They can only appear inside JSON strings, where they are
      # replaced by their equivalent \u escapes.
      JSON_ESCAPE = {
        "<"      => "\\u003c",
        ">"      => "\\u003e",
        "&"      => "\\u0026",
        "\u2028" => "\\u2028",
        "\u2029" => "\\u2029",
      }.freeze
      JSON_ESCAPE_REGEX = Regexp.union(JSON_ESCAPE.keys).freeze

      # Makes a JSON string safe to embed in an HTML <script> element
      def seo_json_escape(input)
        input.to_s.gsub(JSON_ESCAPE_REGEX, JSON_ESCAPE)
      end
    end
  end
end
