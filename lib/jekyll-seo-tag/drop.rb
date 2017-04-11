module Jekyll
  class SeoTag
    class Drop < Jekyll::Drops::Drop
      include Jekyll::SeoTag::JSONLD

      TITLE_SEPARATOR = " | ".freeze
      FORMAT_STRING_METHODS = %i[
        markdownify strip_html normalize_whitespace escape_once
      ].freeze

      def initialize(text, context)
        @obj = {}
        @mutations = {}
        @text    = text
        @context = context
      end

      def version
        Jekyll::SeoTag::VERSION
      end

      # Should the `<title>` tag be generated for this page?
      def title?
        return false unless title
        return @display_title if defined?(@display_title)
        @display_title = (@text !~ %r!title=false!i)
      end

      def site_title
        @site_title ||= format_string(site["title"] || site["name"])
      end

      # Page title without site title or description appended
      def page_title
        @page_title ||= format_string(page["title"] || site_title)
      end

      # Page title with site title or description appended
      def title
        @title ||= begin
          if page["title"] && site_title
            page_title + TITLE_SEPARATOR + site_title
          elsif site["description"] && site_title
            site_title + TITLE_SEPARATOR + format_string(site["description"])
          else
            page_title || site_title
          end
        end
      end

      def name
        return @name if defined?(@name)
        @name = if seo_name
                  seo_name
                elsif !homepage_or_about?
                  nil
                elsif site["social"] && site["social"]["name"]
                  format_string site["social"]["name"]
                elsif site_title
                  format_string site_title
                end
      end

      def description
        @description ||= format_string(
          page["description"] || page["excerpt"] || site["description"]
        )
      end

      # Returns a nil or a hash representing the author
      # Author name will be pulled from:
      #
      # 1. The `author` key, if the key is a string
      # 2. The first author in the `authors` key
      # 3. The `author` key in the site config
      #
      # If the result from the name search is a string, we'll also check
      # to see if the author exists in `site.data.authors`
      def author
        @author ||= begin
          return if author_string_or_hash.to_s.empty?

          author = if author_string_or_hash.is_a?(String)
                     author_hash(author_string_or_hash)
                   else
                     author_string_or_hash
                   end

          author["twitter"] ||= author["name"]
          author["twitter"].delete! "@"
          author.to_liquid
        end
      end

      def date_modified
        @date_modified ||= begin
          date = if page["seo"] && page["seo"]["date_modified"]
                   page["seo"]["date_modified"]
                 else
                   page["last_modified_at"] || page["date"]
                 end
          filters.date_to_xmlschema(date) if date
        end
      end

      def date_published
        @date_published ||= filters.date_to_xmlschema(page["date"]) if page["date"]
      end

      def type
        @type ||= begin
          if page["seo"] && page["seo"]["type"]
            page["seo"]["type"]
          elsif homepage_or_about?
            "WebSite"
          elsif page["date"]
            "BlogPosting"
          else
            "WebPage"
          end
        end
      end

      def links
        @links ||= begin
          if page["seo"] && page["seo"]["links"]
            page["seo"]["links"]
          elsif homepage_or_about? && site["social"] && site["social"]["links"]
            site["social"]["links"]
          end
        end
      end

      def logo
        @logo ||= begin
          return unless site["logo"]
          if absolute_url? site["logo"]
            filters.uri_escape site["logo"]
          else
            filters.uri_escape filters.absolute_url site["logo"]
          end
        end
      end

      # Returns nil or a hash representing the page image
      # The image hash will always contain a path, pulled from:
      #
      # 1. The `image` key if it's a string
      # 2. The `image.path` key if it's a hash
      # 3. The `image.facebook` key
      # 4. The `image.twitter` key
      #
      # The resulting path is always an absolute URL
      def image
        return @image if defined?(@image)

        image = page["image"]
        return @image = nil unless image

        image = { "path" => image } if image.is_a?(String)
        image["path"] ||= image["facebook"] || image["twitter"]

        unless absolute_url? image["path"]
          image["path"] = filters.absolute_url image["path"]
        end

        image["path"] = filters.uri_escape image["path"]

        @image = image.to_liquid
      end

      def page_lang
        @page_lang ||= page["lang"] || site["lang"] || "en_US"
      end

      def canonical_url
        @canonical_url ||= filters.absolute_url(page["url"]).gsub(%r!/index\.html$!, "/")
      end

      private

      def filters
        @filters ||= Jekyll::SeoTag::Filters.new(@context)
      end

      def page
        @page ||= @context.registers[:page].to_liquid
      end

      def site
        @site ||= @context.registers[:site].site_payload["site"].to_liquid
      end

      def homepage_or_about?
        ["/", "/index.html", "/about/"].include? page["url"]
      end

      attr_reader :context

      def fallback_data
        {}
      end

      def absolute_url?(string)
        string.include? "://"
      end

      def format_string(string)
        FORMAT_STRING_METHODS.each do |method|
          string = filters.public_send(method, string)
        end

        string unless string.empty?
      end

      def author_string_or_hash
        @author_string_or_hash ||= begin
          author = page["author"]
          author = page["authors"][0] if author.to_s.empty? && page["authors"]
          author = site["author"] if author.to_s.empty?
          author
        end
      end

      def author_hash(author_string)
        if site.data["authors"] && site.data["authors"][author_string]
          hash = site.data["authors"][author_string]
          hash["twitter"] ||= author_string
          hash
        else
          { "name" => author_string }
        end
      end

      def seo_name
        @seo_name ||= format_string(page["seo"]["name"]) if page["seo"]
      end
    end
  end
end
