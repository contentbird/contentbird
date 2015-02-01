class ChannelsController < ApplicationController
  before_action {section 'channel'}
  before_action :authenticate_user!, :load_service

  def index
    @channels = @channel_service.list
  end

  def show
    @channel             = @channel_service.find(params[:id])
    @publications        = CB::Manage::Publication.new(current_user).list_for_channel(@channel).page()
    @last_publication_at = @channel.last_publication_at
  end

  def new
    @channel = @channel_service.build_new
    load_user_content_types
  end

  def create
    result, @channel = @channel_service.create(channel_params)
    if result
      redirect_to channels_path, notice: t('.notice')
    else
      load_user_content_types
      render :new
    end
  end

  def edit
    @channel   = @channel_service.find(params[:id])
    load_user_content_types
  end

  def update
    updated, @channel = @channel_service.update(params[:id], channel_params)
    if updated
      redirect_to channels_path, notice: t('.notice', channel_name: @channel.name)
    else
      load_user_content_types
      render :edit
    end
  end

  def reset_access_token
    reseted, @token = @channel_service.reset_access_token(params[:id])
    if reseted
      flash[:notice] = t('.notice')
    else
      flash[:alert] = t('.error')
    end
    respond_to do |format|
      format.html { redirect_to :back }
      format.js
    end
  end

  def destroy
    if @channel_service.destroy(params[:id])
      flash[:notice] = t '.notice'
    else
      flash[:alert] = t '.error'
    end
    redirect_to channels_path
  end

  def open
    opened, channel = @channel_service.openit(params[:id])
    if opened
      flash[:notice] = t '.notice'
    else
      flash[:alert] = t '.error'
    end
    redirect_to channels_path
  end

  def close
    closed, channel = @channel_service.closeit(params[:id])
    if closed
      flash[:notice] = t '.notice'
    else
      flash[:alert] = t '.error'
    end
    redirect_to channels_path
  end

private

  def load_service
    @channel_service      = CB::Manage::Channel.new(current_user)
    @content_type_service = CB::Manage::ContentType.new(current_user)
  end

  def load_user_content_types
    @user_types = @content_type_service.user_types
  end

  def channel_params
    params.require(:channel).permit(:name, :url_prefix, :css, :baseline, :cover, :remove_css, sections_attributes: [:id, :label, :title, :position, :forewords, :content_type_id, :channel_id, :mode, :_destroy])
  end
end