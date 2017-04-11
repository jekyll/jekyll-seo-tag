$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "jekyll"
require "jekyll-seo-tag"
require "html-proofer"
require "uri"
require "net/http"

ENV["JEKYLL_LOG_LEVEL"] = "error"

RSpec::Matchers.define :be_valid_json_ld do |_expected|
  match do |actual|
    validate_json_ld(actual)["errors"].empty?
  end

  failure_message do |actual|
    validate_json_ld(actual)["errors"]
  end

  def validate_json_ld(html)
    params = { "html" => html }
    url = URI.parse("https://search.google.com/structured-data/testing-tool/validate")
    response = Net::HTTP.post_form(url, params)
    JSON.parse(response.body.split("\n")[1])
  rescue
    puts "Unable to validate JSON"
    { "errors" => [] }
  end
end

def dest_dir
  File.expand_path("../tmp/dest", File.dirname(__FILE__))
end

def source_dir
  File.expand_path("./fixtures", File.dirname(__FILE__))
end

CONFIG_DEFAULTS = {
  "source"      => source_dir,
  "destination" => dest_dir,
  "gems"        => ["jekyll-seo-tag"],
}.freeze

def make_page(options = {})
  page = Jekyll::Page.new site, CONFIG_DEFAULTS["source"], "", "page.md"
  page.data = options
  page
end

def make_post(options = {})
  filename = File.expand_path("_posts/2015-01-01-post.md", CONFIG_DEFAULTS["source"])
  config = { :site => site, :collection => site.collections["posts"] }
  page = Jekyll::Document.new filename, config
  page.merge_data!(options)
  page
end

def make_site(options = {})
  config = Jekyll.configuration CONFIG_DEFAULTS.merge(options)
  Jekyll::Site.new(config)
end

def make_context(registers = {}, environments = {})
  Liquid::Context.new(environments, {}, { :site => site, :page => page }.merge(registers))
end
