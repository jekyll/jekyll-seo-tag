RSpec.describe Jekyll::SeoTag::Filters do
  let(:page)      { make_page }
  let(:site)      { make_site }
  let(:context)   { make_context(:page => page, :site => site) }
  subject { described_class.new(context) }

  before do
    Jekyll.logger.log_level = :error
  end

  it "stores the context" do
    expect(subject.instance_variable_get("@context")).to be_a(Liquid::Context)
  end

  it "exposes jekyll filters" do
    expect(subject).to respond_to(:markdownify)
  end

  it "exposes liquid standard filters" do
    expect(subject).to respond_to(:normalize_whitespace)
  end
end
