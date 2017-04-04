$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "jekyll"
require "jekyll-seo-tag"
require "html-proofer"

ENV["JEKYLL_LOG_LEVEL"] = "error"

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
