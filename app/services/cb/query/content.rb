class CB::Query::Content

  attr_reader :channel

  def initialize channel
    @channel = channel
  end

  def new_for_section_slug section_slug, attributes={}
    section_found, section = CB::Query::Section.new(channel).find_by_slug(section_slug)
    content_type = section.content_type
    clean_attr = properties_keys_from_names_to_ids(attributes, content_type)
    new_content = CB::Core::Content.new({content_type: section.content_type, owner_id: channel.owner_id}.merge(clean_attr))
    [true, new_content]
  end

  def create_for_section_slug section_slug, attributes
    success, content = new_for_section_slug(section_slug, attributes)
    saved = content.save
    [saved, content]
  end

  private
  def properties_keys_from_names_to_ids attributes, content_type
    return attributes unless attributes[:properties].present?
    prop_names = attributes[:properties].keys
    content_type.properties.each do |prop|
      attributes[:properties][prop.id.to_s] = attributes[:properties][prop.name]
    end
    attributes[:properties].delete_if {|k,v| prop_names.include?(k)}
    attributes
  end
end