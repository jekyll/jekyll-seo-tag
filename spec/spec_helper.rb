$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'jekyll'
require 'jekyll-seo-tag'

CONFIG_DEFAULTS = {
  "source"      => File.expand_path("./fixtures", File.dirname(__FILE__)),
  "destination" => File.expand_path("../tmp/dest",   File.dirname(__FILE__)),
  "gems"        => ["jekyll-seo-tag"]
}

def page(options={})
  page = Jekyll::Page.new site, CONFIG_DEFAULTS["source"], "", "page.md"
  page.data = options
  page
end

def post(options={})
  page = Jekyll::Post.new site, CONFIG_DEFAULTS["source"], "", "2015-01-01-post.md"
  page.data = options
  page
end

def site(options={})
  config = Jekyll.configuration CONFIG_DEFAULTS.merge(options)
  Jekyll::Site.new(config)
end

def context(registers={})
  Liquid::Context.new({}, {}, { :site => site, :page => page }.merge(registers))
end
