# frozen_string_literal: true

RSpec.describe Jekyll::SeoTag do
  let(:config)    { { "title" => "site title" } }
  let(:page_meta) { {} }
  let(:page)      { make_page(page_meta) }
  let(:site)      { make_site(config) }
  let(:render_context) { make_context(:page => page, :site => site) }
  let(:text) { "" }
  let(:tag_name) { "github_edit_link" }
  let(:tokenizer) { Liquid::Tokenizer.new("") }
  let(:parse_context) { Liquid::ParseContext.new }
  let(:rendered) { subject.render(render_context) }
  let(:payload) { subject.send(:payload) }

  subject do
    tag = described_class.parse(tag_name, text, tokenizer, parse_context)
    tag.instance_variable_set("@context", render_context)
    tag
  end

  before do
    Jekyll.logger.log_level = :error
  end

  it "returns the template" do
    expect(described_class.template).to be_a(Liquid::Template)
  end

  context "payload" do
    it "contains the drop" do
      expect(payload["seo_tag"]).to be_a(Jekyll::SeoTag::Drop)
    end

    it "contains the Jekyll drop" do
      expect(payload["jekyll"]).to be_a(Jekyll::Drops::JekyllDrop)
    end

    it "contains the page" do
      expect(payload["page"]).to be_a(Jekyll::Page)
    end

    it "contains the site" do
      expect(payload["site"]).to be_a(Jekyll::Drops::SiteDrop)
    end
  end

  it "renders" do
    expected = "<!-- Begin Jekyll SEO tag v#{described_class::VERSION} -->"
    expect(rendered).to match(expected)
  end
end
