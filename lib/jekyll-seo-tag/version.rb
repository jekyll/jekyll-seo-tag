# Prevent bundler errors
module Liquid; class Tag; end; end

module Jekyll
  class SeoTag < Liquid::Tag
    VERSION = "0.1.4"
  end
end
