module Jekyll
  class SeoTag
    module UrlHelper
      private

      def absolute_url?(string)
        return unless string
        Addressable::URI.parse(string).absolute?
      rescue Addressable::URI::InvalidURIError
        nil
      end
    end
  end
end
