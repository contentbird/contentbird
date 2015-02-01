class PublicationsController < ApplicationController
  before_action :authenticate_user!, :load_services
  layout false

  def index
    @content_id   = params[:content_id]
    @publications = @service.list(@content_id)
  end

  def create
    filtered_params = publication_params
    @published, @publication, @new_section_created = @service.publish(filtered_params[:content_id], filtered_params[:channel_id])
    if @published
      render json: { publication: {id: @publication.id, permalink: @publication.permalink},
                     unpublish_path: publication_path(@publication),
                     show_expiration_path: show_expiration_publication_path(@publication),
                     publications_count: @publication.content.publications_count,
                     new_section_created: @new_section_created,
                     new_section_message: @new_section_created ? t('.notice', url: (@publication.channel.api? ? edit_api_channel_path(@publication.channel_id) : edit_channel_path(@publication.channel_id))) : nil }
    else
      render json: {error: {msg: t('.error')}}, status: 500
    end
  end

  def destroy
    @destroyed, @publication, @manual_unpublication_needed = @service.unpublish(params[:id])
    if @destroyed
      render json: { publish_path: publications_path,
                     publications_count: @publication.content.publications_count,
                     message: (t('.manual_unpublication_needed') if @manual_unpublication_needed) }
    else
      render json: {error: {msg: t('.notice')}}, status: 500
    end
  end

  def show_expiration
    @publication = @service.find params[:id]
  end

  def update_expiration
    updated, result = @service.set_expiration(params[:id], params[:expire_in])
    render json: {updated: updated}.merge(result)
  end

private
  def load_services
    @service = CB::Manage::Publication.new(current_user)
  end
  def publication_params
    params.require(:publication).permit(:channel_id, :content_id)
  end
end