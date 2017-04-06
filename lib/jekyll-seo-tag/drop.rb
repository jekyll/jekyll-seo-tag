module Jekyll
  class SeoTag
    class Drop < Jekyll::Drops::Drop
      TITLE_SEPARATOR = " | "
      include Jekyll::Filters
      include Liquid::StandardFilters

      def initialize(text, context)
        @obj     = {}
        @mutations = {}
        @text    = text
        @context = context
      end

      def version
        Jekyll::SeoTag::VERSION
      end

      # Should the `<title>` tag be generated for this page?
      def title?
        @text !~ %r!title=false!i && title
      end

      def site_title
        format_string(site["title"] || site["name"])
      end

      # Page title without site title or description appended
      def page_title
        format_string(page["title"] || site_title)
      end

      # Page title with site title or description appended
      def title
        if page["title"] && site_title
          format_string(page["title"]) + TITLE_SEPARATOR + site_title
        elsif site["description"] && site_title
          site_title + TITLE_SEPARATOR + format_string(site["description"])
        else
          format_string(page["title"]) || site_title
        end
      end

      def name
        if page["seo"] && page["seo"]["name"]
          format_string page["seo"]["name"]
        elsif homepage_or_about? && site["social"] && site["social"]["name"]
          format_string site["social"]["name"]
        elsif homepage_or_about? && site_title
          format_string site_title
        end
      end

      def description
        format_string(page["description"] || page["excerpt"] || site["description"])
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
        author = page["author"]
        author = page["authors"][0] if author.to_s.empty? && page["authors"]
        author = site["author"] if author.to_s.empty?
        return if author.to_s.empty?

        if author.is_a?(String)
          if site.data["authors"] && site.data["authors"][author]
            author = site.data["authors"][author]
          else
            author = { "name" => author }
          end
        end

        author["twitter"] ||= author["name"]
        author["twitter"].gsub! "@", ""
        author.to_liquid
      end

      def date_modified
        return page["seo"].date_modified if page["seo"] && page["seo"]["date_modified"]
        page["last_modified_at"] || page["date"]
      end

      def type
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

      def links
        if page["seo"] && page["seo"]["links"]
          page["seo"]["links"]
        elsif homepage_or_about? && site["social"] && site["social"]["links"]
          site["social"]["links"]
        end
      end

      # TODO escape
      def logo
        return unless site["logo"]
        if absolute_url? site["logo"]
          site["logo"]
        else
          absolute_url site["logo"]
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
      # TODO escape
      def image
        return unless image = page["image"]

        image = { "path" => image } if image.is_a?(String)
        image["path"] ||= image["facebook"] || image["twitter"]

        unless absolute_url? image["path"]
          image["path"] = absolute_url image["path"]
        end

        image.to_liquid
      end

      def page_lang
        page["lang"] || site["lang"] || "en_US"
      end

      private

      def page
        @page ||= @context.registers[:page].to_liquid
      end

      def site
        @site ||= @context.registers[:site].site_payload["site"].to_liquid
      end

      def homepage_or_about?
        ["/", "/index.html", "/about/"].include? page["url"]
      end

      def context
        @context
      end

      def fallback_data
        {}
      end

      def absolute_url?(string)
        string.include? "://"
      end

      def format_string(string)
        methods = %i(markdownify strip_html normalize_whitespace escape_once)
        methods.each do |method|
          string = public_send(method, string)
        end

        string unless string.empty?
      end
    end
  end
end
