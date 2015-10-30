# Jekyll SEO Tag

A Jekyll plugin to add metadata tags for search engines and social networks to better index and display your site's content.

[![Gem Version](https://badge.fury.io/rb/jekyll-seo-tag.svg)](https://badge.fury.io/rb/jekyll-seo-tag) [![Build Status](https://travis-ci.org/benbalter/jekyll-seo-tag.svg)](https://travis-ci.org/benbalter/jekyll-seo-tag) 

## What it does

Jekyll SEO Tag adds the following meta tags to your site:

* Pages title (with site title appended when available)
* Page description
* Canonical URL
* Next and previous URLs for posts
* [JSON-LD Site and post metadata](https://developers.google.com/structured-data/) for richer indexing
* [Open graph](http://ogp.me/) title, description, site title, and URL (for Facebook, LinkedIn, etc.)
* [Twitter summary card](https://dev.twitter.com/cards/overview) metadata

While you could theoretically add the necessary metadata tags yourself, Jekyll SEO Tag provides a battle-tested template of crowdsourced best-practices.

## What it doesn't do

Jekyll SEO tag is designed to output machine-readable metadata for search engines and social networks to index and display. If you're looking for something to analyze your Jekyll site's structure and content (e.g., more traditional SEO optimization), take a look at [The Jekyll SEO Gem](https://github.com/pmarsceill/jekyll-seo-gem).

Jekyll SEO tag isn't designed to accommodate every possible use case. It should work for most site out of the box and without a laundry list of configuration options that serve only to confuse most users.

## Installation

1. Add the following to your site's `Gemfile`:

  ```ruby
  gem 'jekyll-seo-tag'
  ```

2. Add the following to your site's `_config.yml`:

  ```yml
  gems:
    - jekyll-seo-tag
  ```

3. Add the following right before `</head>` in your site's template(s):

  ```liquid
    {% seo %}
  ```

## Usage

The SEO tag will respect any of the following if included in your site's `_config.yml` (and simply not include them if they're not defined):

* `title` - Your site's title (e.g., Ben's awesome site, The GitHub Blog, etc.)
* `description` - A short description (e.g., A blog dedicated to reviewing cat gifs)
* `url` - The full URL to your site. Note: `site.github.url` will be used by default.
* `twitter:username` - The site's Twitter handle. You'll want to describe it like so:

  ```yml
  twitter:
    username: benbalter
  ```

* `logo` - Relative URL to a site-wide logo (e.g., `assets/your-company-logo.png`)
* `social` - For [specifying social profiles](https://developers.google.com/structured-data/customize/social-profiles). The following properties are available:
  * `type` - Either `person` or `organization` (defaults to `person`)
  * `name` - If the user or organization name differs from the site's name
  * `links` - An array of links to social media profiles.

The SEO tag will respect the following YAML front matter if included in a post, page, or document:

* `title` - The title of the post, page, or document
* `description` - A short description of the page's content
* `image` - The absolute URL to an image that should be associated with the post, page, or document
* `author` - The username of the post, page, or document author
