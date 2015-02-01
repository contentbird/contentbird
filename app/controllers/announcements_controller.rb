class AnnouncementsController < ApplicationController

  before_action :authenticate_user!

  def show
    record_click
    redirect_to ANNOUNCEMENT_URL
  end

  def close
    record_click
    redirect_to :back
  end

private
  def record_click
    current_user.announcement_clicked! ANNOUNCEMENT_CODE
  end

end