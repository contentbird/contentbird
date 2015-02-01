class CB::Manage::Contact

  attr_reader :user

  def initialize user
    @user = user
  end

  def find_or_create_by_email email
    contact = CB::Core::Contact.find_or_create_by(owner_id: user.id, email: email)
    [contact.persisted?, contact]
  end

end