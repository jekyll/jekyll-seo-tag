# frozen_string_literal: true

RSpec.describe Jekyll::SeoTag::AuthorDrop do
  let(:data) { {} }
  let(:config) { { "author" => "site_author" } }
  let(:site) do
    site = make_site(config)
    site.data = data
    site
  end
  let(:site_payload) { site.site_payload["site"] }

  let(:name) { "foo" }
  let(:twitter) { "foo" }
  let(:picture) { nil }
  let(:expected_hash) do
    {
      "name"    => name,
      "twitter" => twitter,
    }
  end

  let(:page_meta) { { "title" => "page title" } }
  let(:page)      { make_page(page_meta) }
  subject { described_class.new(:page => page.to_liquid, :site => site_payload.to_liquid) }

  before do
    Jekyll.logger.log_level = :error
  end

  it "returns the author's name for #to_s" do
    expect(subject.to_s).to eql("site_author")
  end

  context "with site.authors as an array" do
    let("data") { { "authors" => %w(foo bar) } }
    let(:page_meta) { { "author" => "foo" } }

    it "doesn't error" do
      expect(subject.to_h).to eql(expected_hash)
    end
  end

  context "with site.authors[author] as string" do
    let("data") { { "authors" => { "foo" => "bar" } } }
    let(:page_meta) { { "author" => "foo" } }

    it "doesn't error" do
      expect(subject.to_h).to eql(expected_hash)
    end
  end

  [:with, :without].each do |site_data_type|
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

          it "returns the name" do
            expect(subject["name"]).to eql(expected_author)
          end

          it "returns the twitter handle" do
            expect(subject["twitter"]).to eql(expected_author)
          end

          if site_data_type == :with && author_type != :hash
            it "returns arbitrary metadata" do
              expect(subject["image"]).to eql("author.png")
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
      expect(subject["name"]).to eql("front matter default")
    end
  end

  context "twitter" do
    let(:page_meta) { { "author" => "author" } }

    it "pulls the handle from the author" do
      expect(subject["twitter"]).to eql("author")
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
        expect(subject["twitter"]).to eql("twitter")
      end
    end

    # See https://github.com/jekyll/jekyll-seo-tag/issues/202
    context "without an author name or handle" do
      let(:page_meta) { { "author" => { "foo" => "bar" } } }

      it "dosen't blow up" do
        expect(subject["twitter"]).to be_nil
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
        expect(subject["twitter"]).to eql("twitter")
      end
    end
  end
end
