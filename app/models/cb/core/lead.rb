class CB::Core::Lead < ActiveRecord::Base
  validates_format_of     :email, with: Devise.email_regexp
  validates_uniqueness_of :email

  scope :to_invite, -> { where(token: nil) }

  def generate_token!
    return self.token if self.token.present?
    begin
      self.token = SecureRandom.hex
    end while self.class.exists?(token: self.token)
    save!
    self.token
  end

end