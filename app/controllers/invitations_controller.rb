class InvitationsController < ApplicationController
  before_action :authenticate_user!

  def create
    JobRunner.run(SendEmail, 'invitation', 'CB::Core::User', current_user.id, 'email' => params[:email])
    flash[:notice] = t('.notice')
    redirect_to :back
  end

end