class ContentTypesController < ApplicationController
  before_action {section 'content_type'}
  before_action :authenticate_user!, :load_service

  def index
    @types = @service.user_types.with_owner
  end

  def new
    @type = @service.build_new
    load_selectable_types
  end

  def create
    result, @type = @service.create(content_type_params)
    if result
      redirect_to content_types_path, notice: t('.notice')
    else
      load_selectable_types
      render :new
    end
  end

  def edit
    @type = @service.find(params[:id])
    load_selectable_types
    unless @type.owned_by?(current_user)
      @forked_type = @type
      @type = @service.build_forked_type(@forked_type)
      return render :new
    end
  end

  def update
    result, @type = @service.update(params[:id], content_type_params)
    if result
      redirect_to content_types_path, notice: t('.notice')
    else
      load_selectable_types
      render :edit
    end
  end

  def destroy
    if @service.destroy(params[:id])
      flash[:notice] = t '.notice'
    else
      flash[:alert] = t '.error'
    end
    redirect_to content_types_path
  end

  private

  def load_service
    @service = CB::Manage::ContentType.new(current_user)
  end

  def load_selectable_types
    @selectable_types = @service.selectable_types
  end

  def content_type_params
    params.require(:content_type).permit(:title, :title_label, properties_attributes: [:id, :title, :position, :content_type_id, :_destroy])
  end
end