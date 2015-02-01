class ContentsController < ApplicationController
  include ContentHelper
  before_action {section 'content'}
  before_action :authenticate_user!, :load_services

  def index
    @display_mode = set_display_mode
    per_page = @display_mode == 'grid' ? 15 : 6
    if params[:content_type_id].present? && params[:content_type_id] != 'all'
      @type     = @type_service.find(params[:content_type_id])
      contents_query = @content_service.recent_for_type(@type)
    else
      contents_query = @content_service.recent
    end

    contents_query = contents_query.search_on_title(params[:search]) if params[:search].present?

    @contents = contents_query.page(params[:page]).per(per_page)
    @types    = @type_service.user_types
  end

  def show
    @content = @content_service.find(params[:id])
    @type    = @content.content_type
  end

  def new
    @type                     = @type_service.find(params[:content_type_id])
    @newly_created, @content  = @content_service.create(@type, title: t('.new_title', title: @type.translated_title.downcase))
    if @newly_created
      @content.title = nil
    else
      flash[:alert] = t('.error')
      redirect_to contents_path
    end
  end

  def create
    @type            = @type_service.find(params[:content][:content_type_id])
    result, @content = @content_service.create(@type, content_params(@type))
    if result
      redirect_to content_path(@content.id), notice: t('.notice', title: @type.translated_title)
    else
      render :new
    end
  end

  def edit
    @content  = @content_service.find(params[:id])
    @type     = @content.content_type
  end

  def update
    @type            = @type_service.find(params[:content][:content_type_id])
    result, @content = @content_service.update(params[:id], content_params(@type))
    if result
      redirect_to content_path(@content.id), notice: t('.notice', title: @type.translated_title)
    else
      render :edit
    end
  end

  def destroy
    destroyed, content = @content_service.destroy(params[:id])
    type = content.content_type
    if destroyed
      flash[:notice] = t('.notice', type: type.translated_title, content: content.title) unless params[:no_flash].present?
    else
      flash[:alert] = t('.error', type: type.translated_title, content: content.title)
    end
    redirect_to contents_path
  end

  def markdown_preview
    render text: markdown(params[:text])
  end

private

  def load_services
    @type_service    = CB::Manage::ContentType.new(current_user)
    @content_service = CB::Manage::Content.new(current_user)
    @channel_service = CB::Manage::Channel.new(current_user)
  end

  def content_params type
    #params.require(:content).permit(:title, properties: type.properties.map{|p| "#{p.id}"})
    params.require(:content).permit(:title).tap do |whitelisted|
      whitelisted[:properties] = params[:content][:properties]
    end
  end

  def set_display_mode
    return session['content_layout'] = params[:display_mode] if ['cards', 'grid'].include?(params[:display_mode])
    return session['content_layout'] = 'cards' unless session['content_layout'].present?
    session['content_layout']
  end
end