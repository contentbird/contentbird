class CB::Core::SectionSerializer < ActiveModel::Serializer
  root false

  attributes :id, :slug, :title, :mode, :forewords
end