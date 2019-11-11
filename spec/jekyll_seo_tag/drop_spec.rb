# frozen_string_literal: true

RSpec.describe Jekyll::SeoTag::Drop do
  let(:config)    { { "title" => "site title" } }
  let(:page_meta) { { "title" => "page title" } }
  let(:page)      { make_page(page_meta) }
  let(:site)      { make_site(config) }
  let(:context)   { make_context(:page => page, :site => site) }
  let(:text) { "" }
  subject { described_class.new(text, context) }

  before do
    Jekyll.logger.log_level = :error
  end

  # Drop includes liquid filters which expect arguments
  # By default, in drops, `to_h` will call each public method with no arugments
  # Here, that would cause the filters to explode. This test ensures that all
  # public methods don't explode when called without arguments. Don't explode.
  it "doesn't blow up on to_h" do
    expect { subject.to_h }.to_not raise_error
  end

  it "returns the version" do
    expect(subject.version).to eql(Jekyll::SeoTag::VERSION)
  end

  context "title?" do
    it "knows to include the title" do
      expect(subject.title?).to be_truthy
    end

    context "with title=false" do
      let(:text) { "title=false" }

      it "knows not to include the title" do
        expect(subject.title?).to be_falsy
      end
    end

    context "site title" do
      it "knows the site title" do
        expect(subject.site_title).to eql("site title")
      end

      context "with site.name" do
        let(:config) { { "name" => "site title" } }

        it "knows the site title" do
          expect(subject.site_title).to eql("site title")
        end
      end
    end

    context "page title" do
      it "knows the page title" do
        expect(subject.page_title).to eql("page title")
      end

      context "without a page title" do
        let(:page) { make_page }

        it "knows the page title" do
          expect(subject.page_title).to eql("site title")
        end
      end
    end

    context "title" do
      context "with a page and site title" do
        it "builds the title" do
          expect(subject.title).to eql("page title | site title")
        end
      end

      context "with a site description but no page title" do
        let(:page)  { make_page }
        let(:config) do
          { "title" => "site title", "description" => "site description" }
        end

        it "builds the title" do
          expect(subject.title).to eql("site title | site description")
        end
      end

      context "with a site tagline but no page title" do
        let(:page)  { make_page }
        let(:config) do
          { "title" => "site title", "description" => "site description", "tagline" => "site tagline" }
        end

        it "builds the title" do
          expect(subject.title).to eql("site title | site tagline")
        end
      end

      context "with just a page title" do
        let(:site)  { make_site }

        it "builds the title" do
          expect(subject.title).to eql("page title")
        end
      end

      context "with just a site title" do
        let(:page)  { make_page }

        it "builds the title" do
          expect(subject.title).to eql("site title")
        end
      end

      context "without a page or site title" do
        let(:page)  { make_page }
        let(:site)  { make_site }

        it "returns nil" do
          expect(subject.title).to be_nil
        end
      end

      context "with an empty page title" do
        let(:page_meta) { { :title => "" } }

        it "builds the title" do
          expect(subject.title).to eql("site title")
        end
      end

      context "with an empty site title" do
        let(:config) { { :title => "" } }

        it "builds the title" do
          expect(subject.title).to eql("page title")
        end
      end

      context "with an empty page and site title" do
        let(:page_meta) { { :title => "" } }
        let(:config) { { :title => "" } }

        it "returns nil" do
          expect(subject.title).to be_nil
        end
      end
    end
  end

  context "name" do
    context "with seo.name" do
      let(:page_meta) do
        { "seo" => { "name" => "seo name" } }
      end

      it "uses the seo name" do
        expect(subject.name).to eql("seo name")
      end
    end

    context "the index" do
      let(:page_meta) { { "permalink" => "/" } }

      context "with site.social.name" do
        let(:config) { { "social" => { "name" => "social name" } } }

        it "uses site.social.name" do
          expect(subject.name).to eql("social name")
        end
      end

      context "with site.social as an array" do
        let(:config) { { "social" => %w(a b) } }

        it "uses site.social.name" do
          expect(subject.name).to be_nil
        end
      end

      it "uses the site title" do
        expect(subject.name).to eql("site title")
      end
    end

    context "site description" do
      context "with a site description" do
        let(:config) { { :description => "site description " } }

        it "returns the site discription" do
          expect(subject.site_description).to eql("site description")
        end
      end

      context "without a site description" do
        let(:site) { make_site }

        it "returns nil" do
          expect(subject.site_description).to be_nil
        end
      end
    end

    context "page description" do
      context "with a page description" do
        let(:page_meta) { { "description"=> "page description" } }

        it "uses the page description" do
          expect(subject.description).to eql("page description")
        end
      end

      context "with a page excerpt" do
        let(:page_meta) { { "description"=> "page excerpt" } }

        it "uses the page description" do
          expect(subject.description).to eql("page excerpt")
        end
      end

      context "with a site description" do
        let(:config) { { "description"=> "site description" } }

        it "uses the page description" do
          expect(subject.description).to eql("site description")
        end
      end

      context "with no descriptions" do
        let(:page_meta) { { "description" => nil, "excerpt" => nil } }
        let(:config) { { "description"=> nil } }

        it "uses returns nil" do
          expect(subject.description).to be_nil
        end
      end
    end

    context "author" do
      let(:page_meta) { { "author" => "foo" } }

      it "returns an AuthorDrop" do
        expect(subject.author).to be_a(Jekyll::SeoTag::AuthorDrop)
      end

      it "passes page information" do
        expect(subject.author.name).to eql("foo")
      end

      # Regression test to ensure to_liquid is called on site and page
      # before being passed to AuthorDrop
      context "with author as a front matter default" do
        let(:page_meta) { {} }
        let(:config) do
          {
            "defaults" => [
              {
                "scope"  => { "path" => "" },
                "values" => { "author" => "front matter default" },
              },
            ],
          }
        end

        it "uses the author from the front matter default" do
          expect(subject.author["name"]).to eql("front matter default")
        end
      end
    end
  end

  context "date published" do
    let(:config) { { "timezone" => "America/New_York" } }
    let(:page_meta) { { "date" => "2017-01-01" } }

    it "uses page.date" do
      expect(subject.date_published).to eql("2017-01-01T00:00:00-05:00")
    end
  end

  context "date modified" do
    let(:config) { { "timezone" => "America/New_York" } }

    context "with seo.date_modified" do
      let(:page_meta) { { "seo" => { "date_modified" => "2017-01-01" } } }

      it "uses seo.date_modified" do
        expect(subject.date_modified).to eql("2017-01-01T00:00:00-05:00")
      end
    end

    context "with page.last_modified_at" do
      let(:page_meta) { { "last_modified_at" => "2017-01-01" } }

      it "uses page.last_modified_at" do
        expect(subject.date_modified).to eql("2017-01-01T00:00:00-05:00")
      end
    end

    context "date" do
      let(:page_meta) { { "date" => "2017-01-01" } }

      it "uses page.date" do
        expect(subject.date_modified).to eql("2017-01-01T00:00:00-05:00")
      end
    end
  end

  context "type" do
    context "with seo.type set" do
      let(:page_meta) { { "seo" => { "type" => "test" } } }

      it "uses seo.type" do
        expect(subject.type).to eql("test")
      end
    end

    context "with seo as an array" do
      let(:page_meta) { { "seo" => %w(a b) } }

      it "uses seo.type" do
        expect(subject.type).to eql("WebPage")
      end
    end

    context "the homepage" do
      let(:page_meta) { { "permalink" => "/" } }

      it "is a website" do
        expect(subject.type).to eql("WebSite")
      end
    end

    context "the about page" do
      let(:page) { make_page("permalink" => "/about/") }

      it "is a website" do
        expect(subject.type).to eql("WebSite")
      end
    end

    context "a blog post" do
      let(:page_meta) { { "date" => "2017-01-01" } }

      it "is a blog post" do
        expect(subject.type).to eql("BlogPosting")
      end
    end

    it "is a webpage" do
      expect(subject.type).to eql("WebPage")
    end
  end

  context "links" do
    context "with seo.links" do
      let(:page_meta) { { "seo" => { "links" => %w(foo bar) } } }

      it "uses seo.links" do
        expect(subject.links).to eql(%w(foo bar))
      end
    end

    context "with site.social.links" do
      let(:config) { { "social" => { "links"=> %w(a b) } } }

      it "doesn't use site.social.links" do
        expect(subject.links).to be_nil
      end

      context "the homepage" do
        let(:page_meta) { { "permalink" => "/" } }

        it "uses site.social.links" do
          expect(subject.links).to eql(%w(a b))
        end
      end
    end
  end

  context "logo" do
    context "without site.logo" do
      it "returns nothing" do
        expect(subject.logo).to be_nil
      end
    end

    context "with an absolute site.logo" do
      let(:config) { { "logo" => "http://example.com/image.png" } }

      it "uses site.logo" do
        expect(subject.logo).to eql("http://example.com/image.png")
      end
    end

    context "with a relative site.logo" do
      let(:config) do
        {
          "logo" => "image.png",
          "url"  => "http://example.com",
        }
      end

      it "uses site.logo" do
        expect(subject.logo).to eql("http://example.com/image.png")
      end
    end

    context "with a uri-escaped logo" do
      let(:config) { { "logo" => "some image.png" } }

      it "escapes the logo" do
        expect(subject.logo).to eql("/some%20image.png")
      end
    end
  end

  context "image" do
    let(:image) { "foo.png" }
    let(:page_meta) { { "image" => image } }

    it "returns a Drop" do
      expect(subject.image).to be_a(Jekyll::SeoTag::ImageDrop)
    end

    it "returns the image" do
      expect(subject.image["path"]).to eql("/foo.png")
    end
  end

  context "lang" do
    context "with page.lang" do
      let(:page_meta) { { "lang" => "en_GB" } }

      it "uses page.lang" do
        expect(subject.page_lang).to eql("en_GB")
      end
    end

    context "with site.lang" do
      let(:config) { { "lang" => "en_GB" } }

      it "uses site.lang" do
        expect(subject.page_lang).to eql("en_GB")
      end
    end

    context "with nothing" do
      it "defaults" do
        expect(subject.page_lang).to eql("en_US")
      end
    end
  end

  context "homepage_or_about?" do
    [
      "/", "/index.html", "index.html", "/index.htm",
      "/about/", "/about/index.html",
    ].each do |permalink|
      context "when passed '#{permalink}' as a permalink" do
        let(:page_meta) { { "permalink" => permalink } }

        it "knows it's the home or about page" do
          expect(subject.send(:homepage_or_about?)).to be_truthy
        end
      end
    end

    context "a random URL" do
      let(:page_meta) { { "permalink" => "/about-foo/" } }

      it "knows it's not the home or about page" do
        expect(subject.send(:homepage_or_about?)).to be_falsy
      end
    end
  end

  context "canonical url" do
    let(:config) { { :url => "http://example.com" } }

    context "when canonical url is specified for a page" do
      let(:canonical_url) { "https://github.com/jekyll/jekyll-seo-tag/" }
      let(:page_meta) { { "title" => "page title", "canonical_url" => canonical_url } }

      it "uses specified canonical url" do
        expect(subject.canonical_url).to eq(canonical_url)
      end
    end

    context "when canonical url is not specified for a page" do
      it "uses site specific canonical url" do
        expect(subject.canonical_url).to eq("http://example.com/page.html")
      end
    end
  end

  context "pagination" do
    let(:context) do
      make_context(
        { :page => page, :site => site },
        "paginator" => { "page" => 2, "total_pages" => 10 }
      )
    end

    it "render default pagination title" do
      expect(subject.send(:page_number)).to eq("Page 2 of 10 for ")
    end

    context "render custom pagination title" do
      let(:config) { { "seo_paginator_message" => "%<current>s of %<total>s" } }

      it "renders the correct page number" do
        expect(subject.send(:page_number)).to eq("2 of 10")
      end
    end
  end

  it "exposes the JSON-LD drop" do
    expect(subject.json_ld).to be_a(Jekyll::SeoTag::JSONLDDrop)
  end
end
