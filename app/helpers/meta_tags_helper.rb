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
      description: "このWebアプリは、音声による前向きなメッセージを通じて、あなたと仲間に元氣を与え、日々の生活をより豊かにするサービスです。",
      keywords: 'ページキーワード',
      canonical: request.original_url,
      noindex: !Rails.env.production?,
      og: {
        site_name: 'Watune（ウェーチュン）',
        title: 'タイトル',
        description: "このWebアプリは、音声による前向きなメッセージを通じて、あなたと仲間に元氣を与え、日々の生活をより豊かにするサービスです。",
        url: request.original_url,
        image: image_url('ogp.png'),
        locale: 'ja_JP',
      },
      twitter: {
        card: 'summary_large_image',
        site: '@ツイッターのアカウント名',
      },
      fb: {
        app_id: '自身のfacebookのapplication ID'
      }
    }
  end

  def assign_meta_tags(options = {})
    defaults = default_meta_tags
    options.reverse_merge!(defaults)
    site = options[:site]
    title = options[:title]
    description = options[:description]
    keywords = options[:keywords]
    image = options[:image].presence || image_url('placeholder.png')
    configs = {
      separator: '|',
      reverse: true,
      site: site,
      title: title,
      description: description,
      keywords: keywords,
      canonical: request.original_url,
      icon: {
        href: image_url('placeholder.png')
      },
      og: {
        type: 'website',
        title: title.presence || site,
        description: description,
        url: request.original_url,
        image: image,
        site_name: site
      },
      twitter: {
        site: site,
        card: 'summary_large_image',
        image: image
      }
    }
    set_meta_tags(configs)
  end
end
