module MetaTagsHelper
  def x_share_post_url(post)
    user_name = post.user.display_name
    post_content = truncate_post_content(post.body)
    text = if post.user == current_user
             "ウェーブしました！\n投稿内容：\n#{post_content}"
           else
             "#{user_name}さんのウェーブ！\n投稿内容：\n#{post_content}"
           end
    hashtags = 'Watune,ウェーチュン'
    path = user_post_path(username_slug: post.user.username_slug, id: post.id)
    url = full_url(path)
    "https://twitter.com/intent/tweet?text=%0a%0a#{CGI.escape(text)}%0a&url=#{CGI.escape(url)}%0a&hashtags=#{CGI.escape(hashtags)}"
  end

  def truncate_post_content(content)
    max_length = 100
    truncated_content = content.truncate(max_length, omission: '...')
    truncated_content.gsub(/\r\n|\r|\n/, "\n") # 改行を統一
  end

  def show_meta_tags
    assign_meta_tags if display_meta_tags.blank?
    display_meta_tags
  end

  def default_meta_tags
    {
      site: 'Watune（ウェーチュン）',
      title: 'Watune - 音声メッセージで喜びや元氣を共有するアプリ',
      reverse: true,
      separator: '|',
      description: 'このWebアプリは、音声による前向きなメッセージを通じて、あなたと仲間に元氣を与え、日々の生活をより豊かにするサービスです。',
      keywords: '前向き, メッセージ, 音声, 元氣, 喜び, 共有, アプリ, Webアプリ プラットフォーム',
      canonical: request.original_url,
      noindex: !Rails.env.production?,
      og: default_og_tags,
      twitter: default_twitter_tags
    }
  end

  def default_og_tags
    {
      site_name: 'Watune（ウェーチュン）',
      title: 'Watune - 音声メッセージで自分自身と仲間に喜びや元氣を与えるアプリ',
      description: 'このWebアプリは、音声による前向きなメッセージを通じて、あなたと仲間に元氣を与え、日々の生活をより豊かにするサービスです。',
      url: request.original_url,
      image: full_url('/ogp.webp'),
      locale: 'ja_JP'
    }
  end

  def default_twitter_tags
    {
      card: 'summary_large_image',
      site: '@ツイッターのアカウント名',
      title: 'タイトル',
      description: 'このWebアプリは、音声による前向きなメッセージを通じて、あなたと仲間に元氣を与え、日々の生活をより豊かにするサービスです。',
      image: full_url('/ogp.webp')
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
