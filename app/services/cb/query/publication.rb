class CB::Query::Publication

  attr_reader :channel

  def initialize channel
    @channel = channel
  end

  def list
    raise ActiveRecord::RecordNotFound.new('The user does not wish to list his publications feed') if channel.social? && !channel.allow_social_feed?
    [true, CB::Core::Publication.from_channel(channel).with_content_and_type.recent]
  end

  def list_for_home
    list_for_section(channel.home_section)
  end

  def list_for_section section
    return [false, {error: :not_found, message: 'Section not found on this channel'}] unless section.present?
    [true, CB::Core::Publication.from_channel(channel).of_content_type(section.content_type_id).with_content_and_type.recent]
  end

  def list_for_section_slug slug
    list_for_section(section_for_slug(slug))
  end

  def find_by_slug_and_section_slug content_slug, section_slug
    section = section_for_slug(section_slug)
    publication = CB::Core::Publication.from_channel(channel)
                                       .of_content_type(section.content_type_id)
                                       .with_content_and_type
                                       .with_url_alias(content_slug)
                                       .first
    if publication.present?
      [true, publication]
    else
      [false, {error: :not_found, message: 'Publication not found'}]
    end
  end

  def find_by_url_alias url_alias
    publication = CB::Core::Publication.from_channel(channel)
                                       .with_url_alias(url_alias)
                                       .with_content_and_type
                                       .first
    if publication.present?
      [true, publication]
    else
      [false, {error: :not_found, message: 'Publication not found'}]
    end
  end

  private

  def section_for_slug slug
    found, section = CB::Query::Section.new(channel).find_by_slug(slug)
    section
  end

end