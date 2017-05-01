# Prevent bundler errors
module Liquid; class Tag; end; end

module Jekyll
  class SeoTag < Liquid::Tag
    VERSION = "2.2.2".freeze
  end
end
