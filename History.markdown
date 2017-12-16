## HEAD

### Documentation

  * Use gems config key for Jekyll &lt; 3.5.0 ([#255](https://github.com/jekyll/jekyll-seo-tag/pull/#255))

## 2.4.0 / 2017-12-04

### Minor

  * Add meta generator ([#236](https://github.com/jekyll/jekyll-seo-tag/pull/#236))
  * Consistently use self-closing tags ([#246](https://github.com/jekyll/jekyll-seo-tag/pull/#246))
  * Strip null values from JSON-LD hash ([#249](https://github.com/jekyll/jekyll-seo-tag/pull/#249))

### Documentation

  * Avoid deprecation warning when building docs ([#243](https://github.com/jekyll/jekyll-seo-tag/pull/#243))

### Development Fixes

  * Test against latest Rubies ([#242](https://github.com/jekyll/jekyll-seo-tag/pull/#242))
  * Use Nokigiri on CI ([#181](https://github.com/jekyll/jekyll-seo-tag/pull/#181))

## 2.3.0

### Minor Enhancements

  * Use canonical_url specified in page if present ([#211](https://github.com/jekyll/jekyll-seo-tag/pull/#211))
  * Fix for image.path causing an invalid url error ([#228](https://github.com/jekyll/jekyll-seo-tag/pull/#228))
  * Ensure `site.data.authors` is properly formatted before attempting to retrieve author meta ([#227](https://github.com/jekyll/jekyll-seo-tag/pull/#227))
  * Convert author, image, and JSON-LD to dedicated drops ([#229](https://github.com/jekyll/jekyll-seo-tag/pull/#229))
  * Cache parsed template ([#231](https://github.com/jekyll/jekyll-seo-tag/pull/#231))
  * Define path with `__dir__` ([#232](https://github.com/jekyll/jekyll-seo-tag/pull/#232))

### Documentation

  * gems: is deprecated in current Jekyll version of github-pages ([#230](https://github.com/jekyll/jekyll-seo-tag/pull/#230))

## 2.2.3

  * Guard against the author's Twitter handle being Nil when stripping @'s ([#203](https://github.com/jekyll/jekyll-seo-tag/pull/#203))
  * Guard against empty title or description strings ([#206](https://github.com/jekyll/jekyll-seo-tag/pull/#206))

## 2.2.2

### Minor Enhancements

  * Guard against arrays in subhashes ([#197](https://github.com/jekyll/jekyll-seo-tag/pull/#197))
  * Guard against invalid or missing URLs ([#199](https://github.com/jekyll/jekyll-seo-tag/pull/#199))

### Development fixes

  * Remove dynamic GitHub Pages logic from Gemfile ([#194](https://github.com/jekyll/jekyll-seo-tag/pull/#194))

## 2.2.1

  * Convert template logic to a Liquid Drop (significant performance improvement) ([#184](https://github.com/jekyll/jekyll-seo-tag/pull/#184))
  * Fix for JSON-LD validation warning for images missing required properties ([#183](https://github.com/jekyll/jekyll-seo-tag/pull/#183))

## 2.2.0

### Major Enhancements

  * Add author meta ([#103](https://github.com/jekyll/jekyll-seo-tag/pull/#103))
  * Add og:locale support ([#166](https://github.com/jekyll/jekyll-seo-tag/pull/#166))
  * Add support for Bing and Yandex webmaster tools. Closes ([#147](https://github.com/jekyll/jekyll-seo-tag/pull/#147)) ([#148](https://github.com/jekyll/jekyll-seo-tag/pull/#148))
  * Add SEO author and date modified to validate JSON-LD output ([#151](https://github.com/jekyll/jekyll-seo-tag/pull/#151))

### Minor Enhancements

  * Use `|` for title separator ([#162](https://github.com/jekyll/jekyll-seo-tag/pull/#162))
  * Use `og:image` for twitter image ([#174](https://github.com/jekyll/jekyll-seo-tag/pull/#174))

### Development Fixes

  * Style fixes ([#170](https://github.com/jekyll/jekyll-seo-tag/pull/#170)), ([#157](https://github.com/jekyll/jekyll-seo-tag/pull/#157)), ([#149](https://github.com/jekyll/jekyll-seo-tag/pull/#149))
  * Test against latest version of Jekyll ([#171](https://github.com/jekyll/jekyll-seo-tag/pull/#171))
  * Bump dev dependencies ([#172](https://github.com/jekyll/jekyll-seo-tag/pull/#172))
  * Remove Rake dependency ([#180](https://github.com/jekyll/jekyll-seo-tag/pull/#180))

## 2.1.0

### Major Enhancement

  * Use new URL filters ([#123](https://github.com/jekyll/jekyll-seo-tag/pull/#123))

### Minor Enhancements

  * Wraps logo image json data in a publisher property ([#133](https://github.com/jekyll/jekyll-seo-tag/pull/#133))
  * Fix duplicated `escape_once` ([#93](https://github.com/jekyll/jekyll-seo-tag/pull/#93))
  * Simplify minify regex ([#125](https://github.com/jekyll/jekyll-seo-tag/pull/#125))
  * Don't mangle text with newlines ([#126](https://github.com/jekyll/jekyll-seo-tag/pull/#126))

### Documentation

  * Add front matter default example for image ([#132](https://github.com/jekyll/jekyll-seo-tag/pull/#132))
  * Fix tiny typo ([#106](https://github.com/jekyll/jekyll-seo-tag/pull/#106))
  * add example usage of social profiles ([#139](https://github.com/jekyll/jekyll-seo-tag/pull/#139))

### Development

  * Inherit Jekyll's rubocop config for consistency ([#109](https://github.com/jekyll/jekyll-seo-tag/pull/#109))
  * Correct spelling in .travis.yml ([#112](https://github.com/jekyll/jekyll-seo-tag/pull/#112))
