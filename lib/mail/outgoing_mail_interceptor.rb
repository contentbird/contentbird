class OutgoingMailInterceptor

  def self.delivering_email message
    original_to       = message.to
    original_subject  = message.subject

    message.to = TEST_EMAIL

    if message.header["X-SMTPAPI"].nil?
      message.subject = "[#{ENV['APP_NAME']}]#{original_to} #{original_subject}"
    else
      original_smtpapi = JSON.parse(message.header["X-SMTPAPI"].value.gsub(/\\n/, ' '))
      if original_smtpapi["to"].nil?
        message.subject = "[#{ENV['APP_NAME']}]#{original_to} #{original_subject}"
      else
        original_smtpapi["to"] = original_smtpapi["to"].first(2)
        original_smtpapi["sub"]["%first_name%"] = original_smtpapi["sub"]["%first_name%"].first(2)
        original_smtpapi["sub"]["%last_name%"] = original_smtpapi["sub"]["%last_name%"].first(2)

        message.subject = "[#{ENV['APP_NAME']}] [to: #{original_smtpapi["to"].join(' ')}] #{original_subject}"
        original_smtpapi["to"].collect! {|x| TEST_EMAIL }
        message.header["X-SMTPAPI"].value = original_smtpapi.to_json
      end
    end
  end

end