class UserSetupController < ApplicationController
  layout 'full_page'
  before_action :authenticate_user!

  def new
    @website_channel = current_user.first_website_channel
    @social_channels_summary = current_user.number_of_channels_by_provider || {}
  end

  def cancel_website_channel
    redirect_to new_user_setup_path
  end

  def cancel_social_channel
    redirect_to new_user_setup_path
  end
end