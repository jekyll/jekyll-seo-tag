# frozen_string_literal: true

RSpec.describe Jekyll::SeoTag::JSONLDDrop do
  let(:author) { "author" }
  let(:image) { "image" }
  let(:metadata) do
    {
      "title"       => "title",
      "author"      => author,
      "image"       => image,
      "date"        => "2017-01-01",
      "description" => "description",
      "seo"         => {
        "name"          => "seo name",
        "date_modified" => "2017-01-02",
        "links"         => %w(a b),
      },
    }
  end
  let(:config) do
    {
      "logo"     => "logo",
      "timezone" => "America/New_York",
    }
  end
  let(:page)      { make_page(metadata) }
  let(:site)      { make_site(config) }
  let(:context)   { make_context(:page => page, :site => site) }
  let(:page_drop) { Jekyll::SeoTag::Drop.new("", context) }
  subject { described_class.new(page_drop) }

  before do
    Jekyll.logger.log_level = :error
  end

  it "returns the context" do
    expect(subject).to have_key("@context")
    expect(subject["@context"]).to eql("https://schema.org")
  end

  it "returns the type" do
    expect(subject).to have_key("@type")
    expect(subject["@type"]).to eql("BlogPosting")
  end

  it "returns the name" do
    expect(subject).to have_key("name")
    expect(subject["name"]).to eql("seo name")
  end

  it "returns the headline" do
    expect(subject).to have_key("headline")
    expect(subject["headline"]).to eql("title")
  end

  context "author" do
    {
      "string" => "author",
      "hash"   => { "name" => "author" },
    }.each do |key, value|
      context "when passed as a #{key}" do
        let(:author) { value }

        it "returns the author" do
          expect(subject).to have_key("author")
          expect(subject["author"]).to be_a(Hash)
          expect(subject["author"]).to have_key("@type")
          expect(subject["author"]["@type"]).to eql("Person")
          expect(subject["author"]).to have_key("name")
          expect(subject["author"]["name"]).to be_a(String)
          expect(subject["author"]["name"]).to eql("author")
        end
      end
    end
  end

  context "image" do
    context "with image as a string" do
      let(:image) { "image" }

      it "returns the image as a string" do
        expect(subject).to have_key("image")
        expect(subject["image"]).to be_a(String)
        expect(subject["image"]).to eql("/image")
      end
    end

    context "with image as a hash" do
      let(:image) { { "path" => "image", "height" => 5, "width" => 10 } }

      it "returns the image as a hash" do
        expect(subject).to have_key("image")
        expect(subject["image"]).to be_a(Hash)
        expect(subject["image"]).to eql(
          "@type"  => "imageObject",
          "url"    => "/image",
          "height" => 5,
          "width"  => 10
        )
      end
    end
  end

  it "returns the datePublished" do
    expect(subject).to have_key("datePublished")
    expect(subject["datePublished"]).to eql("2017-01-01T00:00:00-05:00")
  end

  it "returns the dateModified" do
    expect(subject).to have_key("dateModified")
    expect(subject["dateModified"]).to eql("2017-01-02T00:00:00-05:00")
  end

  it "returns the description" do
    expect(subject).to have_key("description")
    expect(subject["description"]).to eql("description")
  end

  it "returns the publisher" do
    expect(subject).to have_key("publisher")

    publisher = subject["publisher"]
    expect(publisher).to be_a(Hash)

    expect(publisher).to have_key("@type")
    expect(publisher["@type"]).to eql("Organization")
    expect(publisher).to have_key("logo")

    logo = publisher["logo"]
    expect(logo).to have_key("@type")
    expect(logo["@type"]).to eql("ImageObject")
    expect(logo).to have_key("url")
    expect(logo["url"]).to eql("/logo")
  end

  it "returns the main entity of page" do
    expect(subject).to have_key("mainEntityOfPage")
    expect(subject["mainEntityOfPage"]).to be_a(Hash)
    expect(subject["mainEntityOfPage"]).to have_key("@type")
    expect(subject["mainEntityOfPage"]["@type"]).to eql("WebPage")
    expect(subject["mainEntityOfPage"]).to have_key("@id")
    expect(subject["mainEntityOfPage"]["@id"]).to eql("/page.html")
  end

  it "returns sameAs" do
    expect(subject).to have_key("sameAs")
    expect(subject["sameAs"]).to be_a(Array)
    expect(subject["sameAs"]).to eql(%w(a b))
  end

  it "returns the url" do
    expect(subject).to have_key("url")
    expect(subject["url"]).to eql("/page.html")
  end

  context "with null values" do
    let(:metadata) { {} }

    it "does not return null values as json" do
      expect(subject.to_json).to_not match(%r!:null!)
    end
  end
end
