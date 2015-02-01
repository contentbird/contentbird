class CB::Core::WebsiteChannelSerializer < ActiveModel::Serializer
  root false

  attributes :name, :url_prefix, :baseline, :css_url, :cover_url

  def css_url
    object.css.url
  end
end