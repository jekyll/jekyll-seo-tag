# frozen_string_literal: true

RSpec.describe Jekyll::SeoTag::ImageDrop do
  let(:config)    { { "title" => "site title" } }
  let(:image)     { nil }
  let(:page_meta) { { "image" => image } }
  let(:page)      { make_page(page_meta) }
  let(:site)      { make_site(config) }
  let(:context)   { make_context(:page => page, :site => site) }
  let(:text) { "" }
  subject { described_class.new(:page => page.to_liquid, :context => context) }

  before do
    Jekyll.logger.log_level = :error
  end

  context "with image as a string" do
    let(:image) { "image.png" }

    it "returns the image" do
      expect(subject["path"]).to eql("/image.png")
    end

    context "with site.url" do
      let(:config) { { "url" => "http://example.com" } }

      it "makes the path absolute" do
        expect(subject["path"]).to eql("http://example.com/image.png")
      end
    end

    context "with a URL-escaped path" do
      let(:image) { "some image.png" }

      it "URL-escapes the image" do
        expect(subject["path"]).to eql("/some%20image.png")
      end
    end
  end

  context "with image as a hash" do
    context "with a path" do
      let(:image) { { "path" => "image.png" } }

      it "returns the image" do
        expect(subject["path"]).to eql("/image.png")
      end
    end

    context "with facebook" do
      let(:image) { { "facebook" => "image.png" } }

      it "returns the image" do
        expect(subject["path"]).to eql("/image.png")
      end
    end

    context "with twitter" do
      let(:image) { { "twitter" => "image.png" } }

      it "returns the image" do
        expect(subject["path"]).to eql("/image.png")
      end
    end

    context "with some random hash" do
      let(:image) { { "foo" => "bar" } }

      it "returns nil" do
        expect(subject["path"]).to be_nil
      end

      it "returns arbitrary values" do
        expect(subject["foo"]).to eql("bar")
      end
    end

    context "with an invalid path" do
      let(:image) { ":" }

      it "returns the path" do
        expect(subject["path"]).to eql(":")
      end
    end

    context "with height and width" do
      let(:image) { { "path" => "image.png", "height" => 5, "width" => 10 } }

      it "returns the height and width" do
        expect(subject["height"]).to eql(5)
        expect(subject["width"]).to eql(10)
      end
    end
  end
end
