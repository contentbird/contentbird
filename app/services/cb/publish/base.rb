class CB::Publish::Base
  def self.more
    "..."
  end

  def self.sep
    " "
  end

  def publication_link
    "http://#{channel.url_prefix}.#{WEBSITE_SHORT_DOMAIN}/p/#{@publication.url_alias}"
  end

  def publish publication
    [true, nil]
  end

  def unpublish publication
    [true, nil, true]
  end

  def unpublish_from_provider provider_ref
    true
  end

private

  def force_url_to_http url, protocol='http'
    return nil unless url.present?
    uri = URI.parse(url)
    uri.scheme = protocol
    uri.to_s
  end

end