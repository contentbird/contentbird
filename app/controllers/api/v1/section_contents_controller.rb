class API::V1::SectionContentsController < API::V1::ChannelSecuredController
  skip_before_filter :verify_authenticity_token, only: :create

  def index
    service = rescuer CB::Query::Publication.new(@channel)
    api_response service.list_for_section_slug(params[:section_slug])
  end

  def show
  	service = rescuer CB::Query::Publication.new(@channel)
  	api_response service.find_by_slug_and_section_slug(params[:id], params[:section_slug])
  end

  def new
    service = rescuer CB::Query::Content.new(@channel)
    api_response service.new_for_section_slug(params[:section_slug])
  end

  def create
    service = rescuer CB::Query::Content.new(@channel)
    created, content = service.create_for_section_slug(params[:section_slug], params[:content])
    api_response [true, content]
  end

end