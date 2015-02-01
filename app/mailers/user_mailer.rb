class UserMailer < Devise::Mailer
  require 'email_header.rb'

  def invite_lead lead
    headers['X-SMTPAPI'] = single_recipient_header 'invite_lead'
    @token = lead.token
    mail(to: lead.email, subject: t('.subject'))
  end

  def invitation invitor, args
    headers['X-SMTPAPI'] = single_recipient_header 'invitation'
    @invitor = invitor
    mail(to: args[:email], subject: t('.subject', name: invitor.nest_name.capitalize))
  end

  def email_publication publication
    headers['X-SMTPAPI'] = single_recipient_header 'email_publication'
    @publication = publication
    @channel     = @publication.channel
    @publisher   = @channel.owner
    @content     = @publication.content
    recipients   = @channel.contacts.pluck(:email) + [@publisher.email]
    mail(to: recipients, reply_to: recipients, subject: "[ContentBird] #{@content.title}", from: "#{@publisher.nest_name} via ContentBird <no-reply@contentbird.com>")
  end

private

  def single_recipient_header category, bypass_list_management=false
    hd = EmailHeader.new(nil, category, nil)
    hd.add_filter_setting('bypass_list_management', 'enable', 1) if bypass_list_management
    hd.as_json
  end
end