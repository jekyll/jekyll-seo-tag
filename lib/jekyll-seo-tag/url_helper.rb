# frozen_string_literal: true

module Jekyll
  class SeoTag
    # Mixin to share common URL-related methods between class
    module UrlHelper
      private

      # Determines if the given string is an absolute URL
      #
      # Returns true if an absolute URL
      # Returns false if it's a relative URL
      # Returns nil if it is not a string or can't be parsed as a URL
      def absolute_url?(string)
        return unless string

        Addressable::URI.parse(string).absolute?
      rescue Addressable::URI::InvalidURIError
        nil
      end

      # Collapses consecutive slashes left behind when `site.url` and a
      # relative path are joined and both sides supply one (e.g. `site.url`
      # ending in `/`), without touching the `//` after a URL's scheme.
      #
      # Returns the URL with duplicate path slashes squeezed to one
      def squeeze_url_slashes(url)
        url.to_s.gsub(%r{(?<!:)//+}, "/")
      end
    end
  end
end
