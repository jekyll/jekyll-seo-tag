# frozen_string_literal: true

RSpec.describe Jekyll::SeoTag do
  let(:site_config) { { "url" => "http://example.invalid" } }
  let(:site)      { make_site(site_config) }
  let(:page)      { make_post(page_data) }
  let(:page_data) { {} }
  let(:context)   { make_context(:page => page, :site => site) }
  let(:output)    { Liquid::Template.parse("{% seo %}").render!(context, {}) }
  let(:doc)       { Nokogiri::HTML(output) }
  let(:json)      { output.match(%r!<script type="application/ld\+json">(.*)</script>!m)[1] }
  let(:json_data) { JSON.parse(json) }
  let(:payload)   { '"><script>alert(1)</script><x y="' }
  let(:allowed_elements) { %w(html head body title meta link script) }

  before do
    Jekyll.logger.log_level = :error
  end

  def meta(selector)
    node = doc.at_css(selector)
    expect(node).to_not be_nil, "expected #{selector} in output"
    node["content"] || node["href"]
  end

  shared_examples "no injected markup" do
    it "does not inject elements" do
      expect(doc.css("*").map(&:name) - allowed_elements).to be_empty
      expect(doc.css("script").length).to eql(1)
    end

    it "does not break out of the JSON-LD script" do
      expect(json).to_not match(%r![<>]!)
      expect { json_data }.to_not raise_error
    end
  end

  context "with an author name from site.data.authors" do
    let(:name) { 'Jane "JD" Doe</script><script>alert(document.domain)</script>' }
    let(:site_config) do
      { "url" => "http://example.invalid", "data" => { "authors" => { "jdoe" => { "name" => name } } } }
    end
    let(:page_data) { { "author" => "jdoe" } }

    include_examples "no injected markup"

    it "escapes the author meta tag" do
      expect(output).to include(
        '<meta name="author" content="Jane &quot;JD&quot; Doe&lt;/script&gt;' \
        '&lt;script&gt;alert(document.domain)&lt;/script&gt;" />'
      )
      expect(meta("meta[name='author']")).to eql(name)
    end

    it "escapes the author in the JSON-LD" do
      expect(json).to include('"name":"Jane \"JD\" Doe\u003c/script\u003e\u003cscript\u003e')
      expect(json_data["author"]["name"]).to eql(name)
    end
  end

  context "with an author hash in front matter" do
    let(:site_config) { { "url" => "http://example.invalid", "twitter" => { "username" => "site" } } }
    let(:page_data) do
      { "author" => { "name" => "Eve#{payload}", "twitter" => "eve#{payload}", "url" => "</script><script>alert(1)</script>" } }
    end

    include_examples "no injected markup"

    it "escapes the author name and twitter handle" do
      expect(meta("meta[name='author']")).to eql("Eve#{payload}")
      expect(meta("meta[name='twitter:creator']")).to eql("@eve#{payload}")
    end

    it "preserves the author url in the JSON-LD" do
      expect(json_data["author"]["url"]).to eql("</script><script>alert(1)</script>")
    end
  end

  context "with an author string used as the twitter handle" do
    let(:site_config) { { "url" => "http://example.invalid", "twitter" => { "username" => "site" } } }
    let(:page_data) { { "author" => "Eve#{payload}" } }

    include_examples "no injected markup"

    it "escapes the author meta tags" do
      expect(meta("meta[name='author']")).to eql("Eve#{payload}")
      expect(meta("meta[name='twitter:creator']")).to eql("@Eve#{payload}")
    end
  end

  context "with a canonical_url containing markup" do
    let(:canonical) { "http://example.invalid/#{payload}" }
    let(:page_data) { { "canonical_url" => canonical } }

    include_examples "no injected markup"

    it "escapes the canonical link and og:url" do
      expect(meta("link[rel='canonical']")).to eql(canonical)
      expect(meta("meta[property='og:url']")).to eql(canonical)
      expect(json_data["url"]).to eql(canonical)
    end
  end

  context "with a locale containing markup" do
    let(:page_data) { { "locale" => "en#{payload}" } }

    include_examples "no injected markup"

    it "escapes og:locale" do
      expect(meta("meta[property='og:locale']")).to eql("en#{payload}")
    end
  end

  context "with image attributes containing markup" do
    let(:page_data) do
      {
        "image"   => {
          "path"   => "/img.png?a=1&b=2",
          "alt"    => "alt#{payload}",
          "height" => "1#{payload}",
          "width"  => "2#{payload}",
        },
        "twitter" => { "card" => "summary#{payload}" },
      }
    end

    include_examples "no injected markup"

    it "escapes the image meta tags" do
      expect(meta("meta[property='og:image:alt']")).to eql("alt#{payload}")
      expect(meta("meta[name='twitter:image:alt']")).to eql("alt#{payload}")
      expect(meta("meta[property='og:image:height']")).to eql("1#{payload}")
      expect(meta("meta[property='og:image:width']")).to eql("2#{payload}")
    end

    it "escapes the twitter card" do
      expect(meta("meta[name='twitter:card']")).to eql("summary#{payload}")
    end

    it "escapes ampersands in the image URL" do
      expect(output).to include('<meta property="og:image" content="http://example.invalid/img.png?a=1&amp;b=2" />')
      expect(meta("meta[property='og:image']")).to eql("http://example.invalid/img.png?a=1&b=2")
      expect(json).to include('"url":"http://example.invalid/img.png?a=1\u0026b=2"')
      expect(json_data["image"]["url"]).to eql("http://example.invalid/img.png?a=1&b=2")
    end
  end

  context "with seo.type and seo.links containing a closing script tag" do
    let(:page_data) do
      { "seo" => { "type" => "</script><script>alert(1)</script>", "links" => ["</script><script>alert(2)</script>"] } }
    end

    include_examples "no injected markup"

    it "preserves the values in the JSON-LD" do
      expect(json_data["@type"]).to eql("</script><script>alert(1)</script>")
      expect(json_data["sameAs"]).to eql(["</script><script>alert(2)</script>"])
    end
  end

  context "with an HTML comment opener in the JSON-LD" do
    let(:page_data) { { "author" => "A<!--<script> B" } }

    include_examples "no injected markup"

    it "escapes the comment opener" do
      expect(json).to_not include("<!--")
      expect(json_data["author"]["name"]).to eql("A<!--<script> B")
    end
  end

  context "with owner configuration containing markup" do
    let(:site_config) do
      {
        "url"                     => "http://example.invalid",
        "twitter"                 => { "username" => "site#{payload}" },
        "facebook"                => {
          "admins"    => "admins#{payload}",
          "publisher" => "publisher#{payload}",
          "app_id"    => "app#{payload}",
        },
        "webmaster_verifications" => {
          "google"   => "g#{payload}",
          "bing"     => "b#{payload}",
          "alexa"    => "a#{payload}",
          "yandex"   => "y#{payload}",
          "baidu"    => "bd#{payload}",
          "facebook" => "fb#{payload}",
        },
      }
    end

    include_examples "no injected markup"

    it "escapes the site meta tags" do
      expect(meta("meta[name='twitter:site']")).to eql("@site#{payload}")
      expect(meta("meta[property='fb:admins']")).to eql("admins#{payload}")
      expect(meta("meta[property='article:publisher']")).to eql("publisher#{payload}")
      expect(meta("meta[property='fb:app_id']")).to eql("app#{payload}")
      expect(meta("meta[name='google-site-verification']")).to eql("g#{payload}")
      expect(meta("meta[name='msvalidate.01']")).to eql("b#{payload}")
      expect(meta("meta[name='alexaVerifyID']")).to eql("a#{payload}")
      expect(meta("meta[name='yandex-verification']")).to eql("y#{payload}")
      expect(meta("meta[name='baidu-site-verification']")).to eql("bd#{payload}")
      expect(meta("meta[name='facebook-domain-verification']")).to eql("fb#{payload}")
    end
  end

  context "with site.google_site_verification containing markup" do
    let(:site_config) { { "url" => "http://example.invalid", "google_site_verification" => "g#{payload}" } }

    include_examples "no injected markup"

    it "escapes the verification meta tag" do
      expect(meta("meta[name='google-site-verification']")).to eql("g#{payload}")
    end
  end

  context "with values that are already escaped" do
    let(:page_data) { { "title" => "Tom & Jerry", "description" => "Q&A", "author" => "AT&amp;T" } }

    it "does not double-escape" do
      expect(output).to include('<meta property="og:title" content="Tom &amp; Jerry" />')
      expect(output).to include('<meta name="description" content="Q&amp;A" />')
      expect(output).to include('<meta name="author" content="AT&amp;T" />')
      expect(output).to_not include("&amp;amp;")
    end
  end
end
