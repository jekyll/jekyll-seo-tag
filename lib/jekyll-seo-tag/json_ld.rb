module Jekyll
  class SeoTag
    module JSONLD
      # Unused, but here to preserve backwards compatability
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
    end
  end
end
