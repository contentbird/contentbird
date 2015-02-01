class CB::Core::APIChannelSerializer < ActiveModel::Serializer
  root false

  attributes :name, :url_prefix

end