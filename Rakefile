# frozen_string_literal: true

require "jekyll"

namespace :profile do
  def in_source_dir(*paths)
    source_dir = File.expand_path("tmp/profile_site", __dir__)
    return source_dir if paths.empty?

    paths.reduce(source_dir) { |base, path| File.join(base, path) }
  end
  alias source_dir in_source_dir

  def log(topic, message = "")
    Jekyll.logger.info topic, message.to_s.cyan
  end

  def info(msg)
    Jekyll.logger.info msg.cyan
  end

  task :setup, [:pages, :posts] do |_t, args|
    def create_doc(name, contents)
      File.open(name, "wb") { |f| f.puts contents }
    end

    def create_posts_totalling(count, content)
      log "Creating:", "#{count} posts.."
      t = Time.now.to_i
      until count == 0
        t -= 86_400
        prefix = Time.at(t).strftime("%Y-%m-%d")
        create_doc in_source_dir("_posts", "#{prefix}-hello-world.md"), content
        count -= 1
      end
    end

    def create_pages_totalling(count, content)
      log "Creating:", "#{count} pages.."
      (1..count).each do |index|
        create_doc in_source_dir("pages", "hello-world-#{index}.md"), content
      end
    end

    def create_config_file_with(content)
      log "Creating:", "Config file.."
      create_doc in_source_dir("_config.yml"), content
    end

    args.with_defaults(:pages => 100, :posts => 900)
    no_seo_template = <<~HTML
      <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="{{ '/assets/main.css' | relative_url }}">
        {% feed_meta %}
        {% if jekyll.environment == 'production' and site.google_analytics %}
          {% include google-analytics.html %}
        {% endif %}
      </head>
    HTML

    content = <<~TEXT
      ---
      layout: <LAYOUT>
      author: John Doe
      ---

      Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec semper lacus ac viverra interdum. Quisque in suscipit quam.
      Maecenas vehicula bibendum lacus vitae congue. Vivamus nec molestie leo, eget placerat diam.

      Nullam aliquam nulla pharetra metus sagittis ullamcorper. Praesent interdum lorem sit amet arcu scelerisque pulvinar. Nunc
      suscipit mi nec lectus varius, ac convallis sem facilisis. Duis blandit diam eu interdum tincidunt. Nunc suscipit diam
      tortor, et varius metus mattis a. Morbi at nibh nec velit finibus imperdiet. Sed suscipit volutpat pharetra. Integer nec
      quam tellus.

      Aenean libero eros, semper non efficitur et, consectetur in urna. Aenean ornare at odio ut egestas.
    TEXT

    config_content = <<~YAML
      title: Fixture Site
      description: Fixture site to profile seo-tag plugin
      url: "https://example.com"
      baseurl: "/blog"
      logo: "assets/logo.png"
      theme: minima
    YAML

    Jekyll.logger.info ""
    Jekyll.logger.info "Setting up site.."
    Jekyll.logger.info ""
    mkdir_p in_source_dir("_posts")
    mkdir_p in_source_dir("pages")

    create_posts_totalling args.posts.to_i, content.sub("<LAYOUT>", "post")
    create_pages_totalling args.pages.to_i, content.sub("<LAYOUT>", "page")
    create_config_file_with config_content

    if ENV["SEO_TAG"] == "disabled"
      log "Creating:", "Theme override w/o seo tag.."
      mkdir_p in_source_dir("_includes")
      create_doc in_source_dir("_includes", "head.html"), content
    end
    Jekyll.logger.info ""
    Jekyll.logger.info "setup complete."
  end

  task :memory, [:file] do |_t, args|
    args.with_defaults(:file => "memprof.txt")
    Rake::Task["profile:setup"].invoke unless File.directory?(source_dir)

    require "memory_profiler"
    Jekyll.logger.info ""

    report = MemoryProfiler.report do
      site = Jekyll::Site.new(
        Jekyll.configuration(
          "source"      => source_dir,
          "destination" => in_source_dir("_site")
        )
      )

      Jekyll.logger.info "Source:", site.source
      Jekyll.logger.info "Destination:", site.dest
      Jekyll.logger.info "SEO Tag in theme:", ENV["SEO_TAG"] || "enabled"
      Jekyll.logger.info "Profiling..."

      site.process

      Jekyll.logger.info "", "and done. Generating results.."
      Jekyll.logger.info ""
    end

    if ENV["CI"]
      report.pretty_print(:scale_bytes => true, :color_output => false, :normalize_paths => true)
    else
      FileUtils.mkdir_p("tmp")
      report_file = File.join("tmp", args.file)

      total_allocated_output = report.scale_bytes(report.total_allocated_memsize)
      total_retained_output  = report.scale_bytes(report.total_retained_memsize)

      info "Total allocated: #{total_allocated_output} (#{report.total_allocated} objects)"
      info "Total retained:  #{total_retained_output} (#{report.total_retained} objects)"

      report.pretty_print(:to_file => report_file, :scale_bytes => true, :normalize_paths => true)
      log "\nDetailed Report saved into:", report_file
    end
  end
end
