module ChannelSteps

  def db_find_channel name
    CB::Core::Channel.find_by_name(name)
  end

  def create_channel kind, channel_properties
    visit channels_path
    click_on 'Create'
    click_create_channel_button(kind)
    within '.channels' do
      update_name(channel_properties[:name])
      update_url_prefix(channel_properties[:url_prefix])   if channel_properties[:url_prefix]
      update_baseline(channel_properties[:baseline])       if channel_properties[:baseline]
      channel_properties[:sections].each_with_index do |section, index|
        add_section(section)
      end if channel_properties[:sections]
      update_subscribers(channel_properties[:subscribers]) if channel_properties[:subscribers]
      click_on 'Create channel'
      @accordingly = channel_properties
    end
  end

  def click_create_channel_button kind
    case kind
    when "website"
      find('#createChannel').click_on 'website_channel'
    when "email"
      find('#createChannel').click_on 'social_channel'
      find('#email_provider').click
    end
  end

  def delete_channel channel_name
    @deleted_channel = db_find_channel(channel_name)
    edit_channel channel_name
    click_on 'Delete'
  end

  def update_channel channel_name, channel_changes
    within '.channels #edit_channel' do
      channel_changes.each do |channel_change|
        apply_change(channel_change)
      end
    end
    click_on 'Update channel'
    @accordingly = channel_changes
  end

  def apply_change change
    raise "Hey dude, you can't do that" if (change[:action] == 'add' || change[:action] == 'delete') && !change[:attribute].start_with?('section') && !change[:attribute] == 'subscriber'
    if change[:attribute].start_with?('section')
      if change[:action] == 'add' || change[:action] == 'update'
        raise "Hey dude, when creating or updating a section you should specify changes with & and =" if !change[:value].match(/\&|\=/)
        change_h = hash_of_section_changes(change[:value])
        change[:action] == 'add' ? self.add_section(change_h) : self.update_section(section_name(change[:attribute]), change_h)
      else
        self.delete_section section_name(change[:attribute])
      end
    else
      self.send("#{change[:action]}_#{change[:attribute]}", change[:value])
    end
  end

  def hash_of_section_changes change_value
    h={} ; s= "" ; change_value.split('&').map{|e| s = e.split('=') ; h[s[0].to_sym] = s[1]} ; h
  end

  def section_name attribute
    attribute.split('_').last
  end

  def update_name name
    fill_in 'channel_name', with: name
  end

  def check_name name
    find('.channels #channel_name').value.should eq name
  end

  def update_url_prefix url_prefix
    fill_in 'channel_url_prefix', with: url_prefix
  end

  def check_url_prefix url_prefix
    find('.channels #channel_url_prefix').value.should eq url_prefix
  end

  def update_baseline baseline
    fill_in 'channel_baseline', with: baseline
  end

  def check_baseline baseline
    find('.channels #channel_baseline').value.should eq baseline
  end

  def add_section section_params
    click_on 'Add section'
    update_section(nil, section_params)
  end

  def update_section section_slug, section_params
    selector = section_slug.present? ? find("#section_#{section_slug}") : all("#section_").last
    within selector do
      select section_params[:format], from: 'content_type_id'       if section_params[:format]
      select section_params[:mode],   from: 'mode'                  if section_params[:mode]
      all('.optionsShow').each {|e| e.click } # click_on 'Show options' if link('Show options')
      within '.optionsPanel' do
        fill_in 'title',      with: section_params[:title]          if section_params[:title]
        fill_in 'forewords',  with: section_params[:forewords]      if section_params[:forewords]
      end
    end
  end

  def check_section section_slug, section_params
    within "#section_#{section_slug}" do
      page.should have_select('content_type_id', selected: section_params[:format])  if section_params[:format]
      page.should have_select('mode',            selected: section_params[:mode])    if section_params[:mode]

      click_on 'Show options'
      find_field('title').value.should          eq section_params[:title]      if section_params[:title]
      find_field('forewords').value.should      eq section_params[:forewords]  if section_params[:forewords]
    end
  end

  def delete_section section_slug
    find("#section_#{section_slug} ._removeFields").click
  end

  def check_section_deleted section_slug
    page.should have_no_css("#section_#{section_slug}")
  end

  def check_channel_created channel_name
    current_path.should eq channels_path
    page.body.should have_content 'Your channel was saved'

    channel = db_find_channel(channel_name)
    check_channel_listed channel
  end

  def check_channel_listed channel
    within("#ch_list #ch_#{channel.to_param}") do
      page.should have_text(channel.name)
    end
  end

  def check_channel_not_listed channel
    page.should_not have_css(".channels #ch_#{channel.id}")
  end

  def check_channel_deleted channel_name=nil
    channel = channel_name.nil? ? @deleted_channel : db_find_channel(channel_name)
    current_path.should eq channels_path
    page.body.should have_content "Your channel was deleted"

    check_channel_not_listed channel
  end

  def check_channel_updated_accordingly channel_name
    edit_channel channel_name
    raise_error 'No channel changes remembered. Please set @accordingly to memorize properties between steps' if @accordingly.nil?
    changes = @accordingly
    changes.each do |change|
      case change['action']
      when 'update'
        if change['attribute'].include?('section')
          #when updating section format, its name changes, this ensures the check looks for new section name
          changes = hash_of_section_changes(change['value'])
          check_section(changes[:format].downcase, changes)
        else
          check_name(change['value'])                            if change['attribute'] == 'name'
          check_baseline(change['value'])                        if change['attribute'] == 'baseline'
        end
      when 'delete'
        if change['attribute'].include?('section')
          check_section_deleted(section_name(change['attribute']))
        elsif change['attribute'] == 'subscriber'
          check_subscribers([['delete', change['value']]])
        end
      when 'add'
        if change['attribute'] == 'subscriber'
          check_subscribers([['add', change['value']]])
        end
      end
    end
  end

  def check_channel_detailed_accordingly channel_name
    raise_error 'No channel changes remembered. Please set @accordingly to memorize properties between steps' if @accordingly.nil?
    changes = @accordingly
    check_name(changes[:name])             if changes[:name]
    check_url_prefix(changes[:url_prefix]) if changes[:url_prefix]
    check_baseline(changes[:baseline])     if changes[:baseline]
    within('#sectionsZone') do
      changes[:sections].each_with_index do |section, index|
        page.all('a', text: 'Show options').each {|link| link.click}
        page.should have_select("channel_sections_attributes_#{index}_content_type_id", selected: section[:format])
        page.should have_select("channel_sections_attributes_#{index}_mode",            selected: section[:mode])
        find_field("channel_sections_attributes_#{index}_title").value.should     eq section[:title]
        find_field("channel_sections_attributes_#{index}_forewords").value.should eq section[:forewords]
      end
    end if changes[:sections]
    check_subscribers(changes[:subscribers]) if changes[:subscribers]
  end

  def show_channel channel_name
    visit channels_path
    channel = db_find_channel(channel_name)
    find('#ch_list').click_on("ch_show_#{channel.to_param}")
  end

  def edit_channel channel_name
    visit channels_path
    channel = db_find_channel(channel_name)
    find('#ch_list').click_on("ch_edit_#{channel.to_param}")
  end

  def merge_channel_params(name, prefix, section_properties)
    { name: name, url_prefix: prefix, sections: section_properties.hashes }
  end

end

World(ChannelSteps)

When(/^he creates a new website channel "(.*?)" with prefix "(.*?)" and the following sections$/) do |name, prefix, section_properties|
  create_channel('website', merge_channel_params(name, prefix, section_properties))
end

Then(/^the channel "(.*?)" is created accordingly$/) do |channel_name|
  check_channel_created channel_name
end

When(/^he edits "(.*?)" channel$/) do |channel_name|
  edit_channel channel_name
end

Then(/^"(.*?)" channel is detailed accordingly$/) do |channel_name|
  check_channel_detailed_accordingly channel_name
end

When(/^he updates the channel "(.*?)" like this$/) do |channel_name, channel_changes|
  update_channel(channel_name, channel_changes.hashes)
end

Then(/^channel "(.*?)" is updated accordingly$/) do |channel_name|
  check_channel_updated_accordingly channel_name
end

When(/^he deletes "(.*?)" channel$/) do |channel_name|
  delete_channel channel_name
end

Then(/^channel(?: "(.*?)")? is deleted$/) do |channel_name|
  check_channel_deleted channel_name
end