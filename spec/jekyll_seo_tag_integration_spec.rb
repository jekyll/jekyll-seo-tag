RSpec.describe Jekyll::SeoTag do
  let(:page)      { make_page }
  let(:site)      { make_site }
  let(:post)      { make_post }
  let(:context)   { make_context(:page => page, :site => site) }
  let(:tag)       { "seo" }
  let(:text)      { "" }
  let(:output)    { Liquid::Template.parse("{% #{tag} #{text} %}").render!(context, {}) }
  let(:json)      { output.match(%r!<script type=\"application/ld\+json\">(.*)</script>!m)[1] }
  let(:json_data) { JSON.parse(json) }
  let(:paginator) { { "previous_page" => true, "previous_page_path" => "foo", "next_page" => true, "next_page_path" => "bar" } }

  before do
    Jekyll.logger.log_level = :error
  end

  it "builds" do
    expect(output).to match(%r!Jekyll SEO tag!i)
  end

  it "outputs the plugin version" do
    version = Jekyll::SeoTag::VERSION
    expect(output).to match(%r!Jekyll SEO tag v#{version}!i)
  end

  it "outputs valid HTML" do
    site.process
    options = {
      :check_html       => true,
      :checks_to_ignore => %w(ScriptCheck LinkCheck ImageCheck),
    }
    status = HTMLProofer.check_directory(dest_dir, options).run
    expect(status).to eql(true)
  end

  context "with page.title" do
    let(:page) { make_page("title" => "foo") }

    it "builds the title with a page title only" do
      expect(output).to match(%r!<title>foo</title>!)
      expected = %r!<meta property="og:title" content="foo" />!
      expect(output).to match(expected)
    end

    context "with site.name" do
      let(:site) { make_site("name" => "Site Name") }

      it "builds the title with a page title and site name" do
        expect(output).to match(%r!<title>foo \| Site Name</title>!)
      end
    end

    context "with site.title" do
      let(:site) { make_site("title" => "bar") }

      it "builds the title with a page title and site title" do
        expect(output).to match(%r!<title>foo \| bar</title>!)
      end
    end

    context "with site.description" do
      let(:site) { make_site("description" => "Site Description") }

      it "builds the title without the site description" do
        expect(output).not_to match(%r!<title>foo \| Site Description</title>!)
      end
    end

    context "with site.title and site.description" do
      let(:site) { make_site("title" => "Site Title", "description" => "Site Description") }

      it "builds the title with a page title and site title" do
        expect(output).to match(%r!<title>foo \| Site Title</title>!)
      end

      it "does not build the title with the site description" do
        expect(output).not_to match(%r!<title>foo \| Site Description</title>!)
      end
    end

    context "with site.title and site.description" do
      let(:site) { make_site("title" => "Site Title", "description" => "Site Description") }

      it "builds the title with a page title and site title" do
        expect(output).to match(%r!<title>foo \| Site Title</title>!)
      end

      it "does not build the title with the site description" do
        expect(output).not_to match(%r!<title>Page Title \| Site Description</title>!)
      end
    end
  end

  context "with site.title" do
    let(:site) { make_site("title" => "Site title") }

    it "builds the title with only a site title" do
      expect(output).to match(%r!<title>Site title</title>!)
    end
  end

  context "with site.title and site.description" do
    let(:site) { make_site("title" => "Site Title", "description" => "Site Description") }

    it "builds the title with site title and description" do
      expect(output).to match(%r!<title>Site Title \| Site Description</title>!)
    end
  end

  context "with page.description" do
    let(:page) { make_page("description" => "foo") }

    it "uses the page description" do
      expect(output).to match(%r!<meta name="description" content="foo" />!)
      expect(output).to match(%r!<meta property="og:description" content="foo" />!)
    end
  end

  context "with page.excerpt" do
    let(:page) { make_page("excerpt" => "foo") }

    it "uses the page excerpt when no page description exists" do
      expect(output).to match(%r!<meta name="description" content="foo" />!)
      expect(output).to match(%r!<meta property="og:description" content="foo" />!)
    end
  end

  context "with site.description" do
    let(:site) { make_site("description" => "foo") }

    it "uses the site description when no page description nor excerpt exist" do
      expect(output).to match(%r!<meta name="description" content="foo" />!)
      expect(output).to match(%r!<meta property="og:description" content="foo" />!)
    end
  end

  context "with site.url" do
    let(:site) { make_site("url" => "http://example.invalid") }

    it "uses the site url to build the seo url" do
      expected = %r!<link rel="canonical" href="http://example.invalid/page.html" />!
      expect(output).to match(expected)
      expected = %r!<meta property="og:url" content="http://example.invalid/page.html" />!
      expect(output).to match(expected)
    end

    context "with page.permalink" do
      let(:page) { make_page("permalink" => "/page/index.html") }

      it "uses replaces '/index.html' with '/'" do
        expected = %r!<link rel="canonical" href="http://example.invalid/page/" />!
        expect(output).to match(expected)

        expected = %r!<meta property="og:url" content="http://example.invalid/page/" />!
        expect(output).to match(expected)
      end
    end

    context "with site.baseurl" do
      let(:site) { make_site("url" => "http://example.invalid", "baseurl" => "/foo") }

      it "uses baseurl to build the seo url" do
        expected = %r!<link rel="canonical" href="http://example.invalid/foo/page.html" />!
        expect(output).to match(expected)
        expected = %r!<meta property="og:url" content="http://example.invalid/foo/page.html" />!
        expect(output).to match(expected)
      end
    end

    context "with relative page.image as a string" do
      let(:page) { make_page("image" => "/img/foo.png") }

      it "outputs an open graph image" do
        expected = '<meta property="og:image" content="http://example.invalid/img/foo.png" />'
        expect(output).to include(expected)
      end
    end

    context "with absolute page.image" do
      let(:page) { make_page("image" => "http://cdn.example.invalid/img/foo.png") }

      it "outputs an open graph image" do
        expected = '<meta property="og:image" content="http://cdn.example.invalid/img/foo.png" />'
        expect(output).to include(expected)
      end
    end

    context "with page.image as an object" do
      context "when given a path" do
        let(:page) { make_page("image" => { "path" => "/img/foo.png" }) }

        it "outputs an open graph image" do
          expected = %r!<meta property="og:image" content="http://example.invalid/img/foo.png" />!
          expect(output).to match(expected)
        end
      end

      context "when given a facebook image" do
        let(:page) { make_page("image" => { "facebook" => "/img/facebook.png" }) }

        it "outputs an open graph image" do
          expected = %r!<meta property="og:image" content="http://example.invalid/img/facebook.png" />!
          expect(output).to match(expected)
        end
      end

      context "when given a twitter image" do
        let(:page) { make_page("image" => { "twitter" => "/img/twitter.png" }) }

        it "outputs an open graph image" do
          expected = %r!<meta property="og:image" content="http://example.invalid/img/twitter.png" />!
          expect(output).to match(expected)
        end
      end

      context "when given an image height and width" do
        let(:image) { { "path" => "/img/foo.png", "height" => 1, "width" => 2 } }
        let(:page) { make_page("image" => image) }

        it "outputs an open graph image width and height" do
          expected = %r!<meta property="og:image:height" content="1" />!
          expect(output).to match(expected)
          expected = %r!<meta property="og:image:width" content="2" />!
          expect(output).to match(expected)
        end
      end
    end

    context "with site.logo" do
      let(:site) { make_site("logo" => "/logo.png", "url" => "http://example.invalid") }

      it "outputs the logo" do
        expect(json_data["publisher"]["logo"]["url"]).to eql("http://example.invalid/logo.png")
      end
    end

    context "with absolute site.logo" do
      let(:site) { make_site("logo" => "http://cdn.example.invalid/logo.png", "url" => "http://example.invalid") }

      it "outputs the logo" do
        expect(json_data["publisher"]["logo"]["url"]).to eql("http://cdn.example.invalid/logo.png")
      end
    end

    context "with site.logo and page.author" do
      let(:site) { make_site("logo" => "http://cdn.example.invalid/logo.png", "url" => "http://example.invalid", "author" => "Mr. Foo") }

      it "outputs the author" do
        expect(json_data["publisher"]["name"]).to eql("Mr. Foo")
      end
    end

    context "with page author" do
      let(:site) { make_site("logo" => "/logo.png", "url" => "http://example.invalid") }
      let(:page) { make_post("author" => "Mr. Foo") }

      it "outputs the author" do
        expect(json_data["author"]["@type"]).to eql("Person")
        expect(json_data["author"]["name"]).to eql("Mr. Foo")
      end

      it "outputs the publisher author" do
        expect(json_data["publisher"]["name"]).to eql("Mr. Foo")
      end
    end

    context "with seo type is BlogPosting" do
      let(:site) { make_site("url" => "http://example.invalid") }
      let(:page) { make_post("seo" => { "type" => "BlogPosting" }, "permalink" => "/foo/") }

      it "outputs the mainEntityOfPage" do
        expect(json_data["mainEntityOfPage"]["@type"]).to eql("WebPage")
        expect(json_data["mainEntityOfPage"]["@id"]).to eql("http://example.invalid/foo/")
      end
    end

    context "with seo type is CreativeWork" do
      let(:site) { make_site("url" => "http://example.invalid") }
      let(:page) { make_post("seo" => { "type" => "CreativeWork" }, "permalink" => "/foo/") }

      it "outputs the mainEntityOfPage" do
        expect(json_data["mainEntityOfPage"]["@type"]).to eql("WebPage")
        expect(json_data["mainEntityOfPage"]["@id"]).to eql("http://example.invalid/foo/")
      end
    end

    context "with site.title" do
      let(:site) { make_site("title" => "Foo", "url" => "http://example.invalid") }

      it "outputs the site title meta" do
        expect(output).to match(%r!<meta property="og:site_name" content="Foo" />!)
      end

      it "minifies the output" do
        version = Jekyll::SeoTag::VERSION
        expected = <<-EOS
<!-- Begin Jekyll SEO tag v#{version} -->
<title>Foo</title>
<meta property="og:title" content="Foo" />
<meta property="og:locale" content="en_US" />
<link rel="canonical" href="http://example.invalid/page.html" />
<meta property="og:url" content="http://example.invalid/page.html" />
<meta property="og:site_name" content="Foo" />
EOS
        expect(output).to match(expected)
      end
    end
  end

  context "posts" do
    context "with post meta" do
      let(:site) { make_site("url" => "http://example.invalid") }
      let(:meta) do
        {
          "title"       => "post",
          "description" => "description",
          "image"       => "/img.png",
        }
      end
      let(:page) { make_post(meta) }

      it "outputs post meta" do
        expected = %r!<meta property="og:type" content="article" />!
        expect(output).to match(expected)

        expect(json_data["headline"]).to eql("post")
        expect(json_data["description"]).to eql("description")
        expect(json_data["image"]).to eql("http://example.invalid/img.png")
      end

      it "minifies JSON-LD" do
        expected = <<-EOS.strip
{"@context":"http://schema.org","@type":"BlogPosting","headline":"post",
EOS
        expect(output).to match(expected)
      end
    end
  end

  context "facebook" do
    let(:site_facebook) do
      {
        "admins"    => "jekyllrb-fb-admins",
        "app_id"    => "jekyllrb-fb-app_id",
        "publisher" => "jekyllrb-fb-publisher",
      }
    end

    let(:site) { make_site("facebook" => site_facebook) }

    it "outputs facebook admins meta" do
      expected = %r!<meta property="fb:admins" content="jekyllrb-fb-admins" />!
      expect(output).to match(expected)
    end

    it "outputs facebook app ID meta" do
      expected = %r!<meta property="fb:app_id" content="jekyllrb-fb-app_id" />!
      expect(output).to match(expected)
    end

    it "outputs facebook article publisher meta" do
      expected = %r!<meta property="article:publisher" content="jekyllrb-fb-publisher" />!
      expect(output).to match(expected)
    end
  end

  context "twitter" do
    context "with site.twitter.username" do
      let(:site_twitter) { { "username" => "jekyllrb" } }
      let(:site) { make_site("twitter" => site_twitter) }

      context "with page.author as a string" do
        let(:page) { make_page("author" => "benbalter") }

        it "outputs twitter card meta" do
          expected = %r!<meta name="twitter:card" content="summary" />!
          expect(output).to match(expected)

          expected = %r!<meta name="twitter:site" content="@jekyllrb" />!
          expect(output).to match(expected)

          expected = %r!<meta name="twitter:creator" content="@benbalter" />!
          expect(output).to match(expected)
        end

        context "with an @" do
          let(:page) { make_page("author" => "@benbalter") }

          it "outputs the twitter card" do
            expected = %r!<meta name="twitter:creator" content="@benbalter" />!
            expect(output).to match(expected)
          end
        end

        context "with site.data.authors" do
          let(:author_data) { {} }
          let(:data) { { "authors" => author_data } }
          let(:site) { make_site("data" => data, "twitter" => site_twitter) }

          context "with the author in site.data.authors" do
            let(:author_data) { { "benbalter" => { "twitter" => "test" } } }

            it "outputs the twitter card" do
              expected = %r!<meta name="twitter:creator" content="@test" />!
              expect(output).to match(expected)
            end
          end

          context "without the author in site.data.authors" do
            it "outputs the twitter card" do
              expected = %r!<meta name="twitter:creator" content="@benbalter" />!
              expect(output).to match(expected)
            end
          end
        end
      end

      context "with page.image" do
        let(:page) { make_page("image" => "/img/foo.png") }

        it "outputs summary card with large image" do
          expected = %r!<meta name="twitter:card" content="summary_large_image" />!
          expect(output).to match(expected)
        end
      end

      context "with page.author as a hash" do
        let(:page) { make_page("author" => { "twitter" => "@test" }) }

        it "supports author data as a hash" do
          expected = %r!<meta name="twitter:creator" content="@test" />!
          expect(output).to match(expected)
        end
      end

      context "with page.authors as an array" do
        let(:page) { make_page("authors" => %w(test foo)) }

        it "supports author data as an array" do
          expected = %r!<meta name="twitter:creator" content="@test" />!
          expect(output).to match(expected)
        end
      end

      context "with site.author as a hash" do
        let(:author) { { "twitter" => "@test" } }
        let(:site) { make_site("author" => author, "twitter" => site_twitter) }

        it "supports author data as an hash" do
          expected = %r!<meta name="twitter:creator" content="@test" />!
          expect(output).to match(expected)
        end
      end
    end
  end

  context "author" do
    let(:site) { make_site("author" => "Site Author") }

    context "with site.author" do
      it "outputs site author metadata" do
        expected = %r!<meta name="author" content="Site Author" />!
        expect(output).to match(expected)
      end
    end

    context "with page.author" do
      let(:page) { make_page("author" => "Page Author") }

      it "outputs page author metadata" do
        expected = %r!<meta name="author" content="Page Author" />!
        expect(output).to match(expected)
      end
    end

    context "without page.author" do
      let(:page) { make_page("author" => "") }

      it "outputs site author metadata" do
        expected = %r!<meta name="author" content="Site Author" />!
        expect(output).to match(expected)
      end
    end

    context "with site.data.authors" do
      let(:author_data) { { "renshuki" => { "name" => "Site Data Author" } } }
      let(:data) { { "authors" => author_data } }

      context "with the author in site.data.authors" do
        let(:site) { make_site("data" => data, "author" => "renshuki") }
        it "outputs the author metadata" do
          expected = %r!<meta name="author" content="Site Data Author" />!
          expect(output).to match(expected)
        end
      end

      context "without the author in site.data.authors" do
        it "outputs site author metadata" do
          expected = %r!<meta name="author" content="Site Author" />!
          expect(output).to match(expected)
        end
      end
    end
  end

  context "with site.social" do
    let(:links) { ["http://foo.invalid", "http://bar.invalid"] }
    let(:social_namespace) { { "name" => "Ben", "links" => links } }
    let(:site) { make_site("social" => social_namespace) }
    let(:page) { make_post(meta) }

    context "on homepage" do
      let(:meta) do
        {
          "permalink" => "/",
          "seo"       => {
            "type" => "person",
          },
        }
      end

      it "outputs social meta" do
        expect(json_data["@type"]).to eql("person")
        expect(json_data["name"]).to eql("Ben")
        expect(json_data["sameAs"]).to eql(links)
      end
    end

    context "on about page" do
      let(:meta) { { "permalink" => "/about/" } }

      it "outputs sameAs links" do
        expect(json_data["sameAs"]).to eql(links)
      end
    end

    context "on other pages" do
      let(:meta) { { "permalink" => "/2/" } }

      it "does not output sameAs links" do
        expect(json_data["sameAs"]).to be_nil
      end
    end
  end

  context "with site.name" do
    let(:site) { make_site("name" => "Site name") }

    it "uses site.name if site.title is not present" do
      expected = %r!<meta property="og:site_name" content="Site name" />!
      expect(output).to match(expected)
    end

    context "with site.title" do
      let(:site)  { make_site("name" => "Site Name", "title" => "Site Title") }

      it "uses site.tile if both site.title and site.name are present" do
        expected = %r!<meta property="og:site_name" content="Site Title" />!
        expect(output).to match(expected)
      end
    end
  end

  context "with title=false" do
    let(:text) { "title=false" }

    it "does not output a <title> tag" do
      expect(output).not_to match(%r!<title>!)
    end
  end

  context "with pagination" do
    let(:context) { make_context({}, "paginator" => paginator) }

    it "outputs pagination links" do
      expect(output).to match(%r!<link rel="prev" href="/foo">!)
      expect(output).to match(%r!<link rel="next" href="/bar">!)
    end
  end

  context "webmaster verification" do
    context "with site.webmaster_verifications" do
      let(:site_verifications) do
        {
          "google" => "foo",
          "bing"   => "bar",
          "alexa"  => "baz",
          "yandex" => "bat",
        }
      end

      let(:site) { make_site("webmaster_verifications" => site_verifications) }

      it "outputs google verification meta" do
        expected = %r!<meta name="google-site-verification" content="foo">!
        expect(output).to match(expected)
      end

      it "outputs bing verification meta" do
        expected = %r!<meta name="msvalidate.01" content="bar">!
        expect(output).to match(expected)
      end

      it "outputs alexa verification meta" do
        expected = %r!<meta name="alexaVerifyID" content="baz">!
        expect(output).to match(expected)
      end

      it "outputs yandex verification meta" do
        expected = %r!<meta name="yandex-verification" content="bat">!
        expect(output).to match(expected)
      end
    end

    context "with site.google_site_verification" do
      let(:site) { make_site("google_site_verification" => "foo") }

      it "outputs google verification meta" do
        expected = %r!<meta name="google-site-verification" content="foo" />!
        expect(output).to match(expected)
      end
    end
  end

  context "with locale" do
    it "uses en_US when no locale is specified" do
      expected = %r!<meta property="og:locale" content="en_US" />!
      expect(output).to match(expected)
    end

    context "with site.lang" do
      let(:site)  { make_site("lang" => "en_US") }

      it "uses site.lang if page.lang is not present" do
        expected = %r!<meta property="og:locale" content="en_US" />!
        expect(output).to match(expected)
      end

      context "with page.lang" do
        let(:page)  { make_page("lang" => "en_UK") }

        it "uses page.lang if both site.lang and page.lang are present" do
          expected = %r!<meta property="og:locale" content="en_UK" />!
          expect(output).to match(expected)
        end
      end
    end

    context "with site.lang hyphenated" do
      let(:site)  { make_site("lang" => "en-US") }

      it "coerces hyphen to underscore" do
        expected = %r!<meta property="og:locale" content="en_US" />!
        expect(output).to match(expected)
      end
    end
  end
end
