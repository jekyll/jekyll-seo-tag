# Installing Jekyll SEO Tag

1. Add the following to your site's `Gemfile`:

  ```ruby
  gem 'jekyll-seo-tag'
  ```

2. Add the following to your site's `_config.yml`:

  ```yml
  plugins:
    - jekyll-seo-tag
  ```

If you are using a Jekyll version less than `3.5.0`, use the `gems` key instead of `plugins`.

3. Add the following right before `</head>` in your site's template(s):

<!-- {% raw %} -->
  ```liquid
  {% seo %}
  ```
<!-- {% endraw %} -->

In the same template(s) add a `prefix="og: http://ogp.me/ns#"` attribute to its `<html>` tag:

<!-- {% raw %} -->
```html
<!DOCTYPE html>
<html lang="{{ site.lang | default: "en-US" }}" prefix="og: http://ogp.me/ns#">
  <head>                                    <!--^ Added. -->
    ...
```
<!-- {% endraw %} -->
