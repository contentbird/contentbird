module PublishViaEmailSteps
  def email_received sender_email, recipient_email, email_content
    split_recipient = recipient_email.split('@')
    recipient = [{ raw: raw_email(recipient_email), email: recipient_email, token: split_recipient[0], host: split_recipient[1] }]
    email = FactoryGirl.build(:email, to:      recipient,
                                      from:    sender_email,
                                      subject: email_content[:subject],
                                      body:    email_content[:body])
    post email_processor_path, fake_sendgrid_params(email)
  end

  def fake_sendgrid_params email
    {
      to:      email.to.first[:raw],
      from:    raw_email(email.from),
      subject: email.subject,
      text:    email.body
    }
  end

  def raw_email email_address
    "#{email_address.split('@')[0].upcase} <#{email_address}>"
  end
end

World(PublishViaEmailSteps)

Given(/^"(.*?)" sends an email to "(.*?)" with the following content$/) do |sender_email, recipient_email, email_contents|
  email_contents.hashes.each do |email_content|
    email_received sender_email, recipient_email, email_content
  end
end