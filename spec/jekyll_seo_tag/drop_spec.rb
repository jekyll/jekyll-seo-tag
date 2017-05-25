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
        let(:page_meta) { { "description"=> nil, "excerpt" => nil } }
        let(:config) { { "description"=> nil } }

        it "uses returns nil" do
          expect(subject.description).to be_nil
        end
      end
    end

    context "author" do
      let(:data) { {} }
      let(:config) { { "author" => "site_author" } }
      let(:site) do
        site = make_site(config)
        site.data = data
        site
      end

      %i[with without].each do |site_data_type|
        context "#{site_data_type} site.author data" do
          let(:data) do
            if site_data_type == :with
              {
                "authors" => {
                  "author"        => { "name" => "data_author", "image" => "author.png" },
                  "array_author"  => { "image" => "author.png" },
                  "string_author" => { "image" => "author.png" },
                  "site_author"   => { "image" => "author.png" },
                },
              }
            else
              {}
            end
          end

          {
            :string       => { "author" => "string_author" },
            :array        => { "authors" => %w(array_author author2) },
            :empty_string => { "author" => "" },
            :nil          => { "author" => nil },
            :hash         => { "author" => { "name" => "hash_author" } },
          }.each do |author_type, data|
            context "with author as #{author_type}" do
              let(:page_meta) { data }
              let(:expected_author) do
                "#{author_type}_author".sub("nil_", "site_").sub("empty_string_", "site_")
              end

              it "returns a hash" do
                expect(subject.author).to be_a(Hash)
              end

              it "returns the name" do
                expect(subject.author["name"]).to eql(expected_author)
              end

              it "returns the twitter handle" do
                expect(subject.author["twitter"]).to eql(expected_author)
              end

              if site_data_type == :with && author_type != :hash
                it "returns the image" do
                  expect(subject.author["image"]).to eql("author.png")
                end
              end
            end
          end
        end
      end

      context "with author as a front matter default" do
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

      context "twitter" do
        let(:page_meta) { { "author" => "author" } }

        it "pulls the handle from the author" do
          expect(subject.author["twitter"]).to eql("author")
        end

        context "with an @" do
          let(:page_meta) do
            {
              "author" => {
                "name"    => "author",
                "twitter" => "@twitter",
              },
            }
          end

          it "strips the @" do
            expect(subject.author["twitter"]).to eql("twitter")
          end
        end

        # See https://github.com/jekyll/jekyll-seo-tag/issues/202
        context "without an author name or handle" do
          let(:page_meta) { { "author" => { "foo" => "bar" } } }

          it "dosen't blow up" do
            expect(subject.author["twitter"]).to be_nil
          end
        end

        context "with an explicit handle" do
          let(:page_meta) do
            {
              "author" => {
                "name"    => "author",
                "twitter" => "twitter",
              },
            }
          end

          it "pulls the handle from the hash" do
            expect(subject.author["twitter"]).to eql("twitter")
          end
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
      let(:page) { make_page({ "permalink" => "/about/" }) }

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
    let(:page_meta) { { "image" => image } }

    context "with image as a string" do
      let(:image) { "image.png" }

      it "returns a hash" do
        expect(subject.image).to be_a(Hash)
      end

      it "returns the image" do
        expect(subject.image["path"]).to eql("/image.png")
      end

      context "with site.url" do
        let(:config) { { "url" => "http://example.com" } }

        it "makes the path absolute" do
          expect(subject.image["path"]).to eql("http://example.com/image.png")
        end
      end

      context "with a URL-escaped path" do
        let(:image) { "some image.png" }

        it "URL-escapes the image" do
          expect(subject.image["path"]).to eql("/some%20image.png")
        end
      end
    end

    context "with image as a hash" do
      context "with a path" do
        let(:image) { { "path" => "image.png" } }

        it "returns the image" do
          expect(subject.image["path"]).to eql("/image.png")
        end
      end

      context "with facebook" do
        let(:image) { { "facebook" => "image.png" } }

        it "returns the image" do
          expect(subject.image["path"]).to eql("/image.png")
        end
      end

      context "with twitter" do
        let(:image) { { "twitter" => "image.png" } }

        it "returns the image" do
          expect(subject.image["path"]).to eql("/image.png")
        end
      end

      context "with some random hash" do
        let(:image) { { "foo" => "bar" } }

        it "returns nil" do
          expect(subject.image).to be_nil
        end
      end

      context "with an invalid path" do
        let(:image) { ":" }

        it "returns nil" do
          expect(subject.image["path"]).to eql("/:")
        end
      end

      context "with height and width" do
        let(:image) { { "path" => "image.png", "height" => 5, "width" => 10 } }

        it "returns the height and width" do
          expect(subject.image["height"]).to eql(5)
          expect(subject.image["width"]).to eql(10)
        end
      end
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
end
