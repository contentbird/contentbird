class ContactsController < ApplicationController
  before_action {section 'channel'}
  before_action :authenticate_user!

  def create
    email = params[:email].downcase
    return render(json: { your_own_email: {msg: t('.your_own_email')} }) if current_user.email == email
    success, contact = CB::Manage::Contact.new(current_user).find_or_create_by_email(email)
    if success
      render json: { id: contact.id, email: contact.email }
    else
      render json: { error: {msg: t('.error')} }, status: 500
    end
  end

end