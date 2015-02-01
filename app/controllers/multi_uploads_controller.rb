class MultiUploadsController < ApplicationController
  layout 'modal'

  def  new
    @sub_folder = params[:sub_folder]
  end

end