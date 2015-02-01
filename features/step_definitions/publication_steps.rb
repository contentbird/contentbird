module PublicationSteps

  def db_create_publication user, channel, content, published_at, expire_in
    user = CB::Core::User.last if user.nil?
    published_at = Time.now unless published_at.present?
    expire_in    = nil      unless %w(day week month).include?(expire_in)

    success, publication, new_section_created = CB::Manage::Publication.new(user).publish(content, channel)
    raise "db_create_publication failed for content #{content.name} on channel #{channel.name} : #{publication.errors.messages}" unless success

    publication.expire_at    = expiration_date_from_expire_in(expire_in)
    publication.published_at = published_at
    publication.save!
  end

  def check_number_of_publications nb_publications, content_title=nil
    if content_title.present?
      content = db_find_content(content_title)
      find("#content_#{content.id}").should have_content("#{nb_publications} publications")
    else
      page.should have_content("Published on #{nb_publications} channels")
    end
  end

  def check_publication_widget content, channel, published, expire_in
    widget = find_publish_widget(content, channel)
    if published
      check_published_widget widget, expire_in
    else
      check_unpublished_widget widget
    end
  end

  def check_published_widget widget, expire_in
    widget.find('._timeButn.combo-l').should be_visible
    widget.find('._publishButn.togl-on').should be_visible
    widget.find('._seePublication.combo-r').should be_visible

    check_published_widget_time_state widget, expire_in
  end

  def check_published_widget_time_state widget, expire_in
    if expire_in == 'never'
      widget.should have_css('._timeButn.togl-on')
    else
      widget.should have_css('._timeButn.active')
    end
  end

  def check_unpublished_widget widget
    widget.should_not have_css('._timeButn.combo-l')
    widget.find('._publishButn.togl-off').should be_visible
    widget.should_not have_css('._seePublication.combo-r')
  end

  def check_publication_widget_time_limit widget, expire_in
    check_published_widget_time_state widget, expire_in
    ensure_time_zone_is_revealed(widget)

    if expire_in == 'never'
      widget.should have_no_css("._changeTime[data-expire-in=\"never\"]")
      widget.should have_no_css("._changeTime.active")
    else
      active_button = widget.find("._changeTime.active[data-expire-in=\"never\"]")
      active_button.should be_visible
      active_button.should have_text(expire_in)
    end
  end

  def check_contents_and_publications_list contents_hash
    within("#publications_list") do
      contents_hash = contents_hash.hashes
      contents_hash.size.should eq all('.row').size

      contents_hash.each do |content_hash|
        content_name = content_hash[:content]
        page.should have_link(content_name)

        content = db_find_content(content_name)
        widget  = find_publish_widget(content, @current_channel)
        if content_hash[:expire_in] == 'unpublished'
          check_unpublished_widget widget
        else
          check_publication_widget_time_limit(widget, content_hash[:expire_in])
        end
      end
    end
  end

  def publish_content content, channel
    widget = find("#publish_widget_#{content.id}_#{channel.id}")
    widget.find('._publishButn.togl-off').trigger('click')
  end

  def unpublish_content content, channel
    widget = find("#publish_widget_#{content.id}_#{channel.id}")
    widget.find('._publishButn.togl-on').trigger('click')
  end

  def set_publication_time_limit widget, limit
    unless widget.has_css?('._timeZone')
      time_butn = widget.find('._timeButn')
      time_butn.trigger('click')
    end
    widget.find("._changeTime[data-expire-in=\"#{limit}\"]").trigger('click')
  end

  def find_publish_widget content, channel
    find("#publish_widget_#{content.id}_#{channel.id}")
  end

  def ensure_time_zone_is_revealed widget
    unless widget.has_css?('._timeZone')
      widget.find('._timeButn').trigger('click')
    end
  end

  def unfold_publications_of_content content
    find("#show_pub_#{content.id}").trigger('click')
  end

  def expiration_date_from_expire_in expire_in
    case expire_in
    when 'month'
      1.month.from_now
    when 'week'
      1.week.from_now
    when 'day'
      1.day.from_now
    else
      nil
    end
  end

end

World(PublicationSteps)

Then(/^he sees content "(.*?)" has (\d+) publications?$/) do |content_title, nb_publications|
  check_number_of_publications nb_publications, content_title
end

Then(/^he sees the current content has (\d+) publications?$/) do |nb_publications|
  check_number_of_publications nb_publications
end

When(/^he unfolds publications for content "(.*?)"$/) do |content_title|
  @current_content = db_find_content(content_title)
  unfold_publications_of_content(@current_content)
end

Then(/^he sees the following publications$/) do |publications|
  publications.hashes.each do |publication|
    channel = db_find_channel(publication[:channel])
    check_publication_widget(@current_content, channel, publication[:published]=='yes', publication[:expire_in])
  end
end

When(/^he publishes it to channel "(.*?)"( again)?$/) do |channel_name, useless|
  channel = db_find_channel(channel_name)
  publish_content @current_content, channel
end

When(/^he unpublishes it from channel "(.*?)"$/) do |channel_name|
  channel = db_find_channel(channel_name)
  unpublish_content @current_content, channel
end

When(/^he unpublishes "(.*?)"$/) do |content_name|
  content = db_find_content(content_name)
  unpublish_content content, @current_channel
end

Then(/^he successfully expires its channel "(.*?)" publication from (\d+ )?(.*) to (\d+ )?(.*)$/) do |channel_name, useless, from, useless2, to|
  widget = find_publish_widget(@current_content, db_find_channel(channel_name))
  check_publication_widget_time_limit(widget, from)
  set_publication_time_limit(widget, to)
end

Then(/^he successfully expires its content "(.*?)" publication from (\d+ )?(.*) to (\d+ )?(.*)$/) do |content_name, useless, from, useless2, to|
  widget = find_publish_widget(db_find_content(content_name), @current_channel)
  check_publication_widget_time_limit(widget, from)
  set_publication_time_limit(widget, to)
end

When(/^he goes and publish "(.*?)" on "(.*?)"$/) do |content_name, channel_name|
  channel = db_find_channel(channel_name)
  content = db_find_content(content_name)
  visit content_path(content.id)
  publish_content content, channel
end

Given(/^he created the following publications$/) do |publications|
  publications.hashes.each do |publication|
    channel = db_find_channel publication[:channel]
    content = db_find_content publication[:content]
    db_create_publication(@current_user, channel, content, nil, publication[:expire_in])
  end
end

When(/^he proceeds to "(.*?)" channel$/) do |channel_name|
  @current_channel = db_find_channel(channel_name)
  show_channel channel_name
end

Then(/^he sees the channel has only these publications$/) do |contents_and_publications|
  check_contents_and_publications_list(contents_and_publications)
end