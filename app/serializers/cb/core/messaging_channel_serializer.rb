class CB::Core::MessagingChannelSerializer < ActiveModel::Serializer
  root false

  attributes :name, :url_prefix, :baseline, :allow_social_feed, :css_url, :cover_url, :provider

  def css_url
    object.css.url
  end
end