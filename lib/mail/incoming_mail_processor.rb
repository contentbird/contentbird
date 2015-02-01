class IncomingMailProcessor
  def self.process email
    CB::InMail::Manager.new(email).manage
  end
end
