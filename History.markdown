## HEAD

## 2.2.0

### Major Enhancements

  * Add author meta (#103)
  * Add og:locale support #166
  * Add support for Bing and Yandex webmaster tools. Closes #147 (#148)
  * Add SEO author and date modified to validate JSON-LD output (#151)
  
### Minor Enhancements

  * Use `|` for title separator (#162)
  * Use `og:image` for twitter image (#174)

### Development Fixes

  * Style fixes (#170, #157, #149)
  * Test against latest version of Jekyll (#171)
  * Bump dev dependencies (#172)
  * Remove Rake dependency (#180)

## 2.1.0

### Major Enhancement

  * Use new URL filters (#123)

### Minor Enhancements

  * Wraps logo image json data in a publisher property (#133)
  * Fix duplicated `escape_once` (#93)
  * Simplify minify regex (#125)
  * Don't mangle text with newlines #126

### Documentation

  * Add front matter default example for image (#132)
  * Fix tiny typo (#106)
  * add example usage of social profiles (#139)

### Development

  * Inherit Jekyll's rubocop config for consistency (#109)
  * Correct spelling in .travis.yml (#112)
