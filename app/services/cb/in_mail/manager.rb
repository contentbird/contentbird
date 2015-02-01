class CB::InMail::Manager
  attr_reader :email, :sender, :recipients_email

  VALID_RECIPIENT_EMAILS = ['me@cbdev.me', 'me@cbird.me', 'me@contentbird.me']

  def initialize email
    @email            = email
    @sender           = CB::Core::User.find_by_email email.from
    @recipients_email = email.to.map{|e| e[:email]}
  end

  def manage
    if one_valid_recipient? && sender.present?
      type, type_params        = CB::InMail::Parser.new(email).parse
      content_created, content = CB::Manage::Content.new(sender).create(type, type_params)
    else
      [false, nil]
    end
  end

  def one_valid_recipient?
    recipients_email.each do |recipient_email|
      return true if VALID_RECIPIENT_EMAILS.include?(recipient_email)
    end
    false
  end

end
