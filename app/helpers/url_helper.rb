module UrlHelper
  def media_url media_type, media_path=''
    CB::Core::Media.media_url media_type, media_path
  end

  def channel_media_url media_type, media_path=''
    STORAGE[:"channel_media"][:url] + '/' + media_path
  end

end