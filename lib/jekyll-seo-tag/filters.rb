module JekyllSeoTag
  module Filters
    # This is available in Liquid from version 3 which is required by Jekyll 3
    # Provided here for compatibility with Jekyll 2.x
    def default(input, default_value = ''.freeze)
      if !input || input.respond_to?(:empty?) && input.empty?
        default_value
      else
        input
      end
    end
  end
end
