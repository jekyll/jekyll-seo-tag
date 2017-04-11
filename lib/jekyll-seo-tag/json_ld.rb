module Jekyll
  class SeoTag
    module JSONLD

      # A hash of instance methods => key in resulting JSON-LD hash
      METHODS_KEYS = {
        :json_context   => "@context",
        :type           => "@type",
        :name           => "name",
        :page_title     => "headline",
        :json_author    => "author",
        :json_image     => "image",
        :date_published => "datePublished",
        :date_modified  => "dateModified",
        :description    => "description",
        :publisher      => "publisher",
        :main_entity    => "mainEntityOfPage",
        :links          => "sameAs",
        :canonical_url  => "url",
      }.freeze

      def json_ld
        @json_ld ||= begin
          output = {}
          METHODS_KEYS.each do |method, key|
            value = send(method)
            output[key] = value unless value.nil?
          end
          output
        end
      end

      private

      def json_context
        "http://schema.org"
      end

      def json_author
        return unless author
        {
          "@type" => "Person",
          "name"  => author["name"],
        }
      end

      def json_image
        return unless image
        return image["path"] if image.length == 1

        hash = image.dup
        hash["url"]   = hash.delete("path")
        hash["@type"] = "imageObject"
        hash
      end

      def publisher
        return unless logo
        output = {
          "@type" => "Organization",
          "logo"  => {
            "@type" => "ImageObject",
            "url"   => logo,
          },
        }
        output["name"] = author["name"] if author
        output
      end

      def main_entity
        return unless %w(BlogPosting CreativeWork).include?(type)
        {
          "@type" => "WebPage",
          "@id"   => canonical_url,
        }
      end
    end
  end
end
