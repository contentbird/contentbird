class CB::Manage::Publication

  attr_reader :user

  def initialize user
    @user = user
  end

  def list content_key
    channels     = CB::Manage::Channel.new(user).list
    publications = CB::Manage::Content.new(user).find(content_key).publications_by_channel
    result       = {}
    channels.each{|channel| result[channel] = publications[channel.id.to_s]}
    result
  end

  def list_for_channel channel
    CB::Core::Publication.recent.from_channel(channel).with_content_and_type
  end

  def find key
    CB::Core::Publication.owned_by(user).readonly(false).find(key)
  end

  def publish content_key, channel_key
    content = CB::Manage::Content.new(user).find(content_key)
    channel = CB::Manage::Channel.new(user).find(channel_key)

    #this could be a way to refactor the ifs out (and to get simpler tests)
    #publisher = channel.social? ? CB::Manage::SocialPublication.new(user, channel) : CB::Manage::WebSitePublication.new(user, channel)
    #publisher.publish(content)

    params = {content: content, channel: channel}

    if channel.social? || channel.messaging?
      publication_origin, publication = create_or_undelete_publication(params.merge({url_alias: CB::Core::Publication.generate_url_alias}))
      success, provider_ref = channel.provider_class.new(channel).publish(publication)
      unless success
        publication_origin == :undeleted ? publication.soft_delete : publication.destroy
      end
    else
      new_section_created = channel.create_display_section_for_type_if_none(content.content_type)
      publication_origin, publication = create_or_undelete_publication(params.merge({url_alias: content.slug}))
    end
    publication.content.reload
    [publication.persisted? && !publication.deleted?, publication, new_section_created || false]
  rescue
    [false, nil, false]
  end

  def unpublish key
    publication = key.is_a?(CB::Core::Publication) ? key : CB::Core::Publication.find(key)
    return [false, publication, false] if publication.content.owner_id != user.id
    channel = publication.channel
    manual_unpublication_needed = false
    if channel.social?
      success, result, manual_unpublication_needed = channel.provider_class.new(channel).unpublish(publication)
      unless success
        publication.update_attributes(failed_unpublish_count:        publication.failed_unpublish_count + 1,
                                      last_failed_unpublish_at:      Time.now,
                                      last_failed_unpublish_message: result[:message])
        return [false, result, manual_unpublication_needed]
      end
    end
    deleted = publication.soft_delete
    publication.content.reload
    [deleted, publication, manual_unpublication_needed]
  rescue
    [false, nil, false]
  end

  def set_expiration key, limit
    expire_date = limit_to_expire_date(limit)
    return [false, {error: {msg: 'wrong expire limit parameter'}}] if expire_date == 'not found'

    publication = find(key)

    updated = publication.update_attribute(:expire_at, expire_date)
    [updated, (updated ? {expire_at: publication.expire_at} : {error: {msg: 'Could not update expiration date'}})]
  end

private

  def create_or_undelete_publication params
    if deleted_publication = CB::Core::Publication.first_deleted_for_channel_and_content(params[:channel], params[:content])
      deleted_publication.undelete
      return [:undeleted, deleted_publication]
    else
      [:created, CB::Core::Publication.create(params)]
    end
  end

  def limit_to_expire_date limit
    case limit
    when 'never'
      nil
    when 'day'
      1.day.from_now
    when 'week'
      1.week.from_now
    when 'month'
      1.month.from_now
    else
      'not found'
    end
  end

end