RSpec.describe Jekyll::SeoTag::Drop do
  let(:page)      { make_page({ "title" => "page title" }) }
  let(:site)      { make_site({ "title" => "site title" }) }
  let(:context)   { make_context(:page => page, :site => site) }
  let(:text) { "" }
  subject { described_class.new(text, context) }

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
        let(:site)  { make_site({ "name" => "site title" }) }

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
        let(:site) do
          make_site({ "title" => "site title", "description" => "site description" })
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
    end
  end

  context "name" do
    context "with seo.name" do
      let(:page)  { make_page({ "seo" => { "name" => "seo name" } }) }

      it "uses the seo name" do
        expect(subject.name).to eql("seo name")
      end
    end

    context "the index" do
      let(:page) { make_page({ "permalink" => "/" }) }

      context "with site.social.name" do
        let(:site) { make_site({ "social" => { "name" => "social name" } }) }

        it "uses site.social.name" do
          expect(subject.name).to eql("social name")
        end
      end

      it "uses the site title" do
        expect(subject.name).to eql("site title")
      end
    end

    context "description" do
      context "with a page description" do
        let(:page) { make_page({ "description"=> "page description" }) }

        it "uses the page description" do
          expect(subject.description).to eql("page description")
        end
      end

      context "with a page excerpt" do
        let(:page) { make_page({ "description"=> "page excerpt" }) }

        it "uses the page description" do
          expect(subject.description).to eql("page excerpt")
        end
      end

      context "with a site description" do
        let(:site) { make_site({ "description"=> "site description" }) }

        it "uses the page description" do
          expect(subject.description).to eql("site description")
        end
      end
    end

    context "author" do
      let(:page_data) { {} }
      let(:page) { make_page(page_data) }
      let(:data) { {} }
      let(:site) do
        site = make_site({ "author" => "author" })
        site.data = data
        site
      end

      %i[with without].each do |site_data_type|
        context "#{site_data_type} site.author data" do
          let(:data) do
            if site_data_type == :with
              {
                "authors" => {
                  "author" => { "name" => "Author" },
                },
              }
            else
              {}
            end
          end

          {
            :string       => { "author" => "author" },
            :array        => { "authors" => %w(author author2) },
            :empty_string => { "author" => "" },
            :nil          => { "author" => nil },
            :hash         => { "author" => { "name" => "author" } },
          }.each do |author_type, data|
            context "with author as #{author_type}" do
              let(:page_data) { data }

              it "returns a hash" do
                expect(subject.author).to be_a(Hash)
              end

              it "returns the name" do
                if site_data_type == :with && author_type != :hash
                  expect(subject.author["name"]).to eql("Author")
                else
                  expect(subject.author["name"]).to eql("author")
                end
              end

              it "returns the twitter handle" do
                expect(subject.author["twitter"]).to eql("author")
              end
            end
          end
        end
      end

      context "twitter" do
        let(:page_data) { { "author" => "author" } }

        it "pulls the handle from the author" do
          expect(subject.author["twitter"]).to eql("author")
        end

        context "with an @" do
          let(:page_data) do
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

        context "with an explicit handle" do
          let(:page_data) do
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
end
