class LeadsController < ApplicationController
  layout 'public'

  def new
    @lead = CB::Core::Lead.new
  end

  def create
    created, @lead = CB::Subscribe::Lead.new.create(params[:lead][:email])
    if created
      flash[:notice] = t('.notice')
      redirect_to root_path
    else
      flash[:alert] = t('.error')
      redirect_to new_lead_path
    end

  end
end