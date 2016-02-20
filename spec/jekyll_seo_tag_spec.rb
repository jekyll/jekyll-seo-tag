require 'spec_helper'

describe Jekyll::SeoTag do
  subject { Jekyll::SeoTag.parse('seo', nil, nil, nil) }
  let(:page) { make_page }
  let(:site) { make_site }
  let(:post) { make_post }
  let(:context) { make_context(page: page, site: site) }
  let(:output) { subject.render(context) }

  before do
    Jekyll.logger.log_level = :error
  end

  it 'builds' do
    expect(output).to match(/Jekyll SEO tag/i)
  end

  it 'outputs the plugin version' do
    version = Jekyll::SeoTag::VERSION
    expect(output).to match(/Jekyll SEO tag v#{version}/i)
  end

  context 'with page.title' do
    let(:page) { make_page('title' => 'foo') }

    it 'builds the title with a page title only' do
      expect(output).to match(%r{<title>foo</title>})
      expected = %r{<meta property="og:title" content="foo" />}
      expect(output).to match(expected)
    end

    context 'with site.title' do
      let(:site) { make_site('title' => 'bar') }

      it 'builds the title with a page title and site title' do
        expect(output).to match(%r{<title>foo - bar</title>})
      end
    end
  end

  context 'with site.title' do
    let(:site) { make_site('title' => 'Site title') }

    it 'builds the title with only a site title' do
      expect(output).to match(%r{<title>Site title</title>})
    end
  end

  context 'with page.description' do
    let(:page) { make_page('description' => 'foo') }

    it 'uses the page description' do
      expect(output).to match(%r{<meta name="description" content="foo" />})
      expect(output).to match(%r{<meta property='og:description' content="foo" />})
    end
  end

  context 'with page.excerpt' do
    let(:page) { make_page('excerpt' => 'foo') }

    it 'uses the page excerpt when no page description exists' do
      expect(output).to match(%r{<meta name="description" content="foo" />})
      expect(output).to match(%r{<meta property='og:description' content="foo" />})
    end
  end

  context 'with site.description' do
    let(:site) { make_site('description' => 'foo') }

    it 'uses the site description when no page description nor excerpt exist' do
      expect(output).to match(%r{<meta name="description" content="foo" />})
      expect(output).to match(%r{<meta property='og:description' content="foo" />})
    end
  end

  context 'with site.url' do
    let(:site) { make_site('url' => 'http://example.invalid') }

    it 'uses the site url to build the seo url' do
      expected = %r{<link rel="canonical" href="http://example.invalid/page.html" />}
      expect(output).to match(expected)
      expected = %r{<meta property='og:url' content='http://example.invalid/page.html' />}
      expect(output).to match(expected)
    end

    context 'with page.permalink' do
      let(:page) { make_page('permalink' => '/page/index.html') }

      it "uses replaces '/index.html' with '/'" do
        expected = %r{<link rel="canonical" href="http://example.invalid/page/" />}
        expect(output).to match(expected)

        expected = %r{<meta property='og:url' content='http://example.invalid/page/' />}
        expect(output).to match(expected)
      end
    end

    context 'with site.baseurl' do
      let(:site) { make_site('url' => 'http://example.invalid', 'baseurl' => '/foo') }
      it 'uses baseurl to build the seo url' do
        expected = %r{<link rel="canonical" href="http://example.invalid/foo/page.html" />}
        expect(output).to match(expected)
        expected = %r{<meta property='og:url' content='http://example.invalid/foo/page.html' />}
        expect(output).to match(expected)
      end
    end

    context 'with page.image' do
      let(:page) { make_page('image' => 'foo.png') }

      it 'outputs the image' do
        expected = %r{<meta property="og:image" content="http://example.invalid/foo.png" />}
        expect(output).to match(expected)
      end
    end

    context 'with site.logo' do
      let(:site) { make_site('logo' => 'logo.png', 'url' => 'http://example.invalid') }

      it 'outputs the logo' do
        data = output.match(%r{<script type=\"application/ld\+json\">(.*)</script>}m)[1]
        data = JSON.parse(data)

        expect(data['logo']).to eql('http://example.invalid/logo.png')
        expect(data['url']).to eql('http://example.invalid')
      end
    end

    context 'with site.title' do
      let(:site) { make_site('title' => 'Foo', 'url' => 'http://example.invalid') }

      it 'outputs the site title meta' do
        expect(output).to match(%r{<meta property="og:site_name" content="Foo" />})
        data = output.match(%r{<script type=\"application/ld\+json\">(.*)</script>}m)[1]

        data = JSON.parse(data)
        expect(data['name']).to eql('Foo')
        expect(data['url']).to eql('http://example.invalid')
      end
    end
  end

  context 'with site.github.url' do
    let(:github_namespace) { { 'url' => 'http://example.invalid' } }
    let(:site) { make_site('github' => github_namespace) }

    it 'uses site.github.url to build the seo url' do
      expected = %r{<link rel="canonical" href="http://example.invalid/page.html" \/>}
      expect(output).to match(expected)
      expected = %r{<meta property='og:url' content='http://example.invalid/page.html' />}
      expect(output).to match(expected)
    end
  end

  context 'posts' do
    context 'with post meta' do
      let(:meta) do
        {
          'title'       => 'post',
          'description' => 'description',
          'image'       => '/img.png'
        }
      end
      let(:page) { make_post(meta) }

      it 'outputs post meta' do
        expected = %r{<meta property="og:type" content="article" />}
        expect(output).to match(expected)
        data = output.match(%r{<script type=\"application/ld\+json\">(.*)</script>}m)[1]
        data = JSON.parse(data)

        expect(data['headline']).to eql('post')
        expect(data['description']).to eql('description')
        expect(data['image']).to eql('/img.png')
      end
    end
  end

  context 'twitter' do
    context 'with site.twitter.username' do
      let(:site) { make_site('twitter' => { 'username' => 'jekyllrb' }) }

      context 'with page.author as a string' do
        let(:page) { make_page('author' => 'benbalter') }

        it 'outputs twitter card meta' do
          expected = %r{<meta name="twitter:site" content="@jekyllrb" />}
          expect(output).to match(expected)

          expected = %r{<meta name="twitter:creator" content="@benbalter" />}
          expect(output).to match(expected)
        end
      end

      context 'with page.author as an object' do
        let(:page) { make_page('author' => { 'twitter' => '@test' }) }

        it 'supports author data as an object' do
          expected = %r{<meta name="twitter:creator" content="@test" />}
          expect(output).to match(expected)
        end
      end
    end
  end

  context 'with site.social' do
    let(:links) { ['http://foo.invalid', 'http://bar.invalid'] }
    let(:social_namespace) { { 'name' => 'Ben', 'links' => links } }
    let(:site) { make_site('social' => social_namespace) }

    it 'outputs social meta' do
      data = output.match(%r{<script type=\"application/ld\+json\">(.*)</script>}m)[1]
      data = JSON.parse(data)

      expect(data['@type']).to eql('person')
      expect(data['name']).to eql('Ben')
      expect(data['sameAs']).to eql(links)
    end
  end

  context 'with site.name' do
    let(:site) { make_site('name' => 'Site name') }

    it 'uses site.name if site.title is not present' do
      expected = %r{<meta property="og:site_name" content="Site name" />}
      expect(output).to match(expected)
    end

    context 'with site.title' do
      let(:site)  { make_site('name' => 'Site Name', 'title' => 'Site Title') }

      it 'uses site.tile if both site.title and site.name are present' do
        expected = %r{<meta property="og:site_name" content="Site Title" />}
        expect(output).to match(expected)
      end
    end
  end

  it 'outputs valid HTML' do
    site.process
    options = {
      check_html: true,
      checks_to_ignore: %w(ScriptCheck LinkCheck ImageCheck)
    }
    status = HTML::Proofer.new(dest_dir, options).run
    expect(status).to eql(true)
  end
end
