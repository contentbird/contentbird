class CB::Core::ContentSerializer < ActiveModel::Serializer
  root false

  attributes :id, :type, :title, :slug, :properties, :errors

  def type
    object.content_type.name
  end

  def properties
    object.exportable_properties
  end

  def include_errors?
    object.errors.any?
  end
end
