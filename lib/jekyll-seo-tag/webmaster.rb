# frozen_string_literal: true

module Jekyll
  class SeoTag
    class Webmaster
      META_MAP = {
        "alexa"    => "alexaVerifyID",
        "baidu"    => "baidu-site-verification",
        "bing"     => "msvalidate.01",
        "facebook" => "facebook-domain-verification",
        "google"   => "google-site-verification",
        "yandex"   => "yandex-verification",
      }.freeze
      META_KEYS = Set.new(META_MAP.keys).freeze
      private_constant :META_MAP, :META_KEYS

      def self.render(data)
        return unless data.is_a?(Hash)

        @render ||= data.map do |key, value|
          %(<meta name="#{META_MAP[key]}" content="#{value}" />) if META_KEYS.include?(key)
        end.join("\n")
      end
    end
    private_constant :Webmaster
  end
end
