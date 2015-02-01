module CB::Core::Media
  def self.media_url media_type, media_path=''
    STORAGE[:"content_#{media_type}"][:url] + "/#{media_path}"
  end

  def self.thumbnail_url url
    return nil if url.nil?
    url.gsub(/(?<path>.*)\.([a-z|A-Z]*)$/, '\k<path>_thumb.jpg')
  end

  def self.static_asset_url path
    "#{STATIC_ASSET_URL}/#{path}"
  end

  def self.link_image_url domain
    static_asset_url("link-images/#{domain}.jpg")
  end

  def self.image_for_url url
    youtube_id = url.match(/^(https?:\/\/)(www\.)?(youtu\.be|youtube\.com)\/(embed\/|v\/|watch\?v=|watch\?.+&v=)([^&]*)(.*)$/).try(:[], 5)
    return image_for_youtube(youtube_id) if youtube_id.present?

    dailymotion_id = url.match(/^(https?:\/\/)(www\.)?dailymotion.com\/video\/([^_&#\/]*)(.*)$/).try(:[], 3)
    return image_for_dailymotion(dailymotion_id) if dailymotion_id.present?

    domain_name = url.match(/^(https?:\/\/)(www\.|open\.)?([^\.]*).(.*)$/).try(:[], 3)
    return link_image_url(domain_name) if ['vimeo', 'soundcloud', 'spotify', 'deezer'].include?(domain_name)
  end

  def self.image_for_youtube id
    "//img.youtube.com/vi/#{id}/0.jpg"
  end

  def self.image_for_dailymotion id
    "//www.dailymotion.com/thumbnail/video/#{id}"
  end
end