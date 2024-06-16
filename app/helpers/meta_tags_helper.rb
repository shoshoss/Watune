module MetaTagsHelper
  def show_meta_tags
    assign_meta_tags if display_meta_tags.blank?
    display_meta_tags
  end

  def default_meta_tags
    {
      site: 'Watune（ウェーチュン）',
      title: 'タイトル',
      reverse: true,
      separator: '|',
      description: 'このWebアプリは、音声による前向きなメッセージを通じて、あなたと仲間に元氣を与え、日々の生活をより豊かにするサービスです。',
      keywords: 'ページキーワード',
      canonical: request.original_url,
      noindex: !Rails.env.production?,
      og: {
        site_name: 'Watune（ウェーチュン）',
        title: 'ogタイトル',
        description: 'このWebアプリは、音声による前向きなメッセージを通じて、あなたと仲間に元氣を与え、日々の生活をより豊かにするサービスです。',
        url: request.original_url,
        image: full_url('/ogp.webp'),
        locale: 'ja_JP'
      },
      twitter: {
        card: 'summary_large_image',
        site: '@ツイッターのアカウント名',
        title: 'タイトル',
        description: 'このWebアプリは、音声による前向きなメッセージを通じて、あなたと仲間に元氣を与え、日々の生活をより豊かにするサービスです。',
        image: full_url('/ogp.webp')
      },
      fb: {
        app_id: '自身のfacebookのapplication ID'
      }
    }
  end

  def assign_meta_tags(options = {})
    defaults = default_meta_tags
    options.reverse_merge!(defaults)
    configs = build_meta_tags(options)
    set_meta_tags(configs)
  end

  private

  def build_meta_tags(options)
    {
      separator: '|',
      reverse: true,
      site: options[:site],
      title: options[:title],
      description: options[:description],
      keywords: options[:keywords],
      canonical: request.original_url,
      og: build_og_meta_tags(options),
      twitter: build_twitter_meta_tags(options)
    }
  end

  def build_og_meta_tags(options)
    {
      type: 'website',
      title: options[:title].presence || options[:site],
      description: options[:description],
      url: request.original_url,
      image: options[:image].presence || full_url('/ogp.webp'),
      site_name: options[:site]
    }
  end

  def build_twitter_meta_tags(options)
    {
      card: 'summary_large_image',
      site: options[:twitter_site] || '@ツイッターのアカウント名',
      title: options[:title].presence || options[:site],
      description: options[:description],
      image: options[:image].presence || full_url('/ogp.webp')
    }
  end

  def full_title(page_title = '')
    base_title = 'Watune（ウェーチュン）'
    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

  def full_url(path)
    domain = if Rails.env.development?
               'http://0.0.0.0:3000'
             else
               'https://www.watune.com'
             end
    "#{domain}#{path}"
  end
end
