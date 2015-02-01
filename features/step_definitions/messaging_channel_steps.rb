module MessagingChannelSteps
  def db_create_messaging_channel provider, name, subscriber_emails
    user = CB::Core::User.last if user.nil?
    channel_service = CB::Manage::MessagingChannel.new(user)

    created, channel = channel_service.create({name: name, provider: provider})
    raise "db_create_messaging_channel failed for provider #{provider} with name #{name} : #{channel.errors.messages}" unless created

    subscriber_emails.each do |email|
      contact = CB::Core::Contact.create!(email: email)
      channel.subscriptions.create!(contact_id: contact.id)
    end

    channel
  end

  def check_publication_email recipient_emails, content
    sleep(0.2)
    publisher = CB::Core::User.last
    recipient_emails.each do |recipient_email|
      open_email(recipient_email, with_subject: "[ContentBird] #{content.title}")
      #check link to content
      body = current_email.default_part_body.to_s
      body.should include("#{publisher.nest_name} (#{publisher.email}) shares this content with you via")
      body.should have_link(content.title)
      #check link to unsubscribe
      body.should have_link('unsubscribe here')
    end
  end

  def unsubscribe_user_from_last_email subscriber_email
    open_email(subscriber_email)
    visit_in_email("unsubscribe here")
    fill_in 'email', with: subscriber_email
    click_on 'Unsubscribe me'
    page.should have_text('We removed your email')
  end

  def check_subscribers_presence emails_hash
    emails_hash.each do |email, presence|
      presence ? check_subscriber_present(email) : check_subscriber_not_present(email)
    end
  end

  def check_subscriber_present(email)
    within('#subscriptions_list') { page.should(have_text(email)) }
  end

  def check_subscriber_not_present(email)
    within('#subscriptions_list') { page.should(have_no_text(email)) }
  end

  def check_subscribers emails_hash
    emails_hash.each do |action, email|
      case action
      when 'add'
        check_subscriber_present(email)
      when 'delete'
        check_subscriber_not_present(email)
      else
        raise "Hey dude, I don't know how to #{action} a subscriber"
      end
    end
  end

  def update_subscribers emails_updates
    emails_updates.each do |email_update|
      case email_update[0]
      when 'add'
        add_subscriber email_update[1]
      when 'delete'
        delete_subscriber email_update[1]
      else
        raise "Hey dude, I don't know how to #{email_update[0]} a subscriber"
      end
    end
    sleep(0.3)
  end

  def add_subscriber email
    fill_in 'new_contact_email', with: email
    find('#add_contact').click
  end

  def delete_subscriber email
    contact = CB::Core::Contact.find_by_email(email)
    within('#subscriptions_list') {find("#contact_#{contact.id} .contact a").click}
  end

  def merge_messaging_channel_params(name, subscribers)
    { name: name, subscribers: subscribers.map{|email| ['add', email]} }
  end

end

World(MessagingChannelSteps)

Given(/^he created a "(.*?)" messaging channel "(.*?)" with "(.*?)" as subscribers?$/) do |provider, name, subscriber_emails|
  db_create_messaging_channel(provider, name, subscriber_emails.split(', '))
end

When(/^he creates a "(.*?)" messaging channel "(.*?)" with "(.*?)" as subscribers$/) do |provider, name, subscriber_emails|
  create_channel(provider, merge_messaging_channel_params(name, subscriber_emails.split(', ')))
end

Then(/^"(.*?)" receive a publication email for content "(.*?)"$/) do |recipient_emails, content_name|
  content = db_find_content(content_name)
  check_publication_email(recipient_emails.split(', '), content)
end

When(/^"(.*?)" unsubscribes from the received email$/) do |subscriber_email|
  unsubscribe_user_from_last_email subscriber_email
end

Then(/^"(.*?)" (is|is not) in "(.*?)" mailing list$/) do |unsubscribed_email, is_or_not, channel_name|
  channel = db_find_channel(channel_name)
  visit messaging_channel_path(channel)
  check_subscribers_presence("#{unsubscribed_email}" => (is_or_not == 'is'))
end