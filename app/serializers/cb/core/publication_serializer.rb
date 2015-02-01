class CB::Core::PublicationSerializer < ActiveModel::Serializer
  root false

  attributes :published_at, :type, :title, :slug, :first_image, :thumbnail, :first_text, :properties

  def type
    object.content.content_type.name
  end

  def title
    object.content.title
  end

  def slug
    object.url_alias
  end

  def first_image
    object.content.first_image_property_key
  end

  def thumbnail
    object.content.first_image_property_url
  end

  def first_text
    object.content.first_textual_property_key
  end

  def properties
    object.content.exportable_properties
  end
end