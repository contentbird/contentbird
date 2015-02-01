require "mail/incoming_mail_processor"

Griddler.configure do |config|
  config.processor_class = IncomingMailProcessor
  config.to = :hash
  config.reply_delimiter = '-- REPLY ABOVE THIS LINE --'
  config.email_service = :sendgrid
end