module PublicationHelper

  def unpublish_countdown expire_at
    if expire_at < 1.hour.from_now
      t('next_hour')
    else
      time_ago_in_words(expire_at)
    end
  end

  def time_button publication, timeframe
    active = publication.expire_at.present? && date_in_time_frame?(publication.expire_at, timeframe)
    link_to t("publications.show_expiration.limit.#{timeframe}"),
            update_expiration_publication_path(publication),
            class: "butn _changeTime#{' active' if active}",
            data: {expire_in: active ? 'never' : timeframe.to_s}
  end

  def publish_button channel, publication, content_id
    time_btn    = link_to '', publication ? show_expiration_publication_path(publication) : '#', data: {icon: raw("&#xe618;")}, class: "butn-no-text combo-l _timeButn#{(publication && publication.expire_at) ? ' active' : ' togl-on'}", style: (publication ? '' : 'display: none')
    time_panel  = content_tag :div, class: "show-time _timeZone", style: "display:none;" do
    end
    publish_btn = link_to channel.name,
                  publication ? publication_path(publication) : publications_path,
                  class: "butn _publishButn#{publication ? ' combo togl-on' : ' togl-off'}",
                  data: { icon: raw(channel_picto(channel)),
                          content_id: publication ? publication.content_id : content_id,
                          channel_id: channel.id,
                          publication_id: publication.try(:id),
                          action: (publication ? 'unpublish' : 'publish') }
    see_btn     = link_to '', (publication ? publication.permalink(channel) : '#'), data: {icon: raw("&#xe606;")}, class: 'butn-no-text combo-r togl-on _seePublication', target: '_blank', style: (publication ? '' : 'display: none')
    time_btn + time_panel + publish_btn + see_btn
  end

private

  def date_in_time_frame? date, timeframe
    case timeframe
    when :day
      date <= 24.hours.from_now
    when :week
      date > 24.hours.from_now && date <= 7.days.from_now
    when :month
      date > 7.days.from_now
    else
      false
    end
  end

end