class PropagatePropertiesChanges < JobBase
  acts_as_scalable

  @queue = :propagate_properties_changes

  def self.do_perform content_type_id
    type = CB::Core::ContentType.find(content_type_id)
    properties = type.properties.includes(:content_type)
    type.contents.each do |content|
      content.set_exportable_properties(properties)
      content.save!
    end
  end
end