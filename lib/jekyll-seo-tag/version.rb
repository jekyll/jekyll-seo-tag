# Prevent bundler errors
module Liquid; class Tag; end; end

module Jekyll
  class SeoTag < Liquid::Tag
    VERSION = "1.0.0"
  end
end
