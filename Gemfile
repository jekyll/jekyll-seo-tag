source 'https://rubygems.org'
require 'json'
require 'open-uri'

gemspec

group :development, :test do
  versions = JSON.parse(open('https://pages.github.com/versions.json').read)
  versions.delete('ruby')
  versions.delete('jekyll-seo-tag')
  versions.delete('github-pages')
  versions.delete('jekyll') # Remove this line when GitHub Pages supports 3.3.0

  versions.each do |dep, version|
    gem dep, version
  end
end
