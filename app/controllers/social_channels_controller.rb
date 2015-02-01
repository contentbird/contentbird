class SocialChannelsController < ChannelsController
  skip_before_filter :verify_authenticity_token, only: :new

  def new
    if oauth_info
      @channel = @channel_service.build_new(oauth: oauth_info)
      if request.env['omniauth.origin'] == new_user_setup_url
        @channel.owner_id = current_user.id
        @channel.save_with_new_url_prefix
        redirect_to new_user_setup_url
      elsif request.env['omniauth.origin'].present? && (matchdata = request.env['omniauth.origin'].match(/social_channels\/(\d+)/))
        @channel_service.update_credentials(matchdata[1], oauth_info)
        redirect_to request.env['omniauth.origin']
      else
        load_user_content_types
      end
    else
      render :choose
    end
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
  end

  def check_credentials
    @credentials_ok, result = @channel_service.check_credentials(params[:id])
    if @credentials_ok
      @credentials = result[:credentials]
    else
      @error_message = result[:message]
      @provider      = result[:provider]
    end
  rescue
    @credentials_ok = false
    @error_message  = 'Unknown error, please retry later'
  end

  def fail
    redirect_to params[:origin]
  end

private

  def load_service
    @channel_service      = CB::Manage::SocialChannel.new(current_user)
    @content_type_service = CB::Manage::ContentType.new(current_user)
  end

  def oauth_info
    request.env['omniauth.auth']
  end

  def channel_params
    params.require(:channel).permit(:name, :url_prefix, :baseline, :cover, :css, :allow_social_feed, :provider, :provider_oauth_token, :provider_oauth_secret, sections_attributes: [:id, :label, :title, :position, :content_type_id, :channel_id, :_destroy])
  end

end