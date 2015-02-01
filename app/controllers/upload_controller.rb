class UploadController < ApplicationController
  layout 'modal'

  def new
    @field_name = params[:field]
    @storage = storage_for_media_type(params[:media_type])
    @path_prefix = path_prefix_for_media_type(params[:media_type], params[:sub_folder])
  end

  def sign_form
    @transport        = params[:transport] || (request.env['HTTP_USER_AGENT'].match(/MSIE/) ? 'iframe' : 'xhr')
    @storage          = Storage.new(params[:storage_name].to_sym)
    @image_name       = params[:doc][:title]
    extension         = params[:doc][:extension]

    respond_to do |format|
      format.json {
        render json: {
          policy:                   upload_policy(),
          signature:                upload_signature(),
          key:                      upload_key(@image_name, Time.now, extension),
          success_action_redirect:  upload_upload_done_url
        }
      }
    end
  end

  def upload_done
    render :text => 'done', :layout => false, :content_type => "text/plain"
  end

private

  def upload_policy
    return @policy if @policy
    if @storage.local?
      ret = {"expiration" => 5.minutes.from_now.utc.xmlschema,
        "conditions" =>  [
          ["starts-with", "$key", @image_name]
        ]
      }
    elsif @storage.provider == 'Google'
      ret = {"expiration" => 5.minutes.from_now.utc.xmlschema,
        "conditions" =>  [
          ["starts-with", "$key", @image_name],
          {"acl" => "public-read"},
          ['starts-with','$Content-Type','image/'],
          ["content-length-range", 0, @storage.max_size]
        ]
      }
    elsif @storage.provider == 'AWS'
      ret = {"expiration" => 5.minutes.from_now.utc.xmlschema,
        "conditions" =>  [
          {"bucket" => @storage.bucket },
          ["starts-with", "$key", @image_name],
          {"acl" => "public-read"},
          ['starts-with','$Content-Type','image/'],
          ["content-length-range", 0, @storage.max_size]
        ]
      }
    end

    ret['conditions'] << {"success_action_redirect" => upload_upload_done_url} if @transport == 'iframe'

    @policy = Base64.encode64(ret.to_json).gsub(/\n/,'')
  end

  def upload_signature
    Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), @storage.secret_key, upload_policy)).gsub("\n","")
  end

  def upload_key name, time, extension
    "#{name}_#{time.strftime('%Y-%m-%d_%I-%M-%S')}.#{extension}"
  end

  def storage_for_media_type media_type
    if media_type == 'cover'
      Storage.new(:channel_media)
    elsif media_type == 'image'
      Storage.new(:content_image)
    end
  end

  def path_prefix_for_media_type media_type, sub_folder=nil
    if media_type == 'cover'
      path_prefix  = 'cover'
    elsif media_type == 'image'
      path_prefix  = "#{current_user.id}"
      path_prefix  += "/#{sub_folder}" if sub_folder.present?
      path_prefix
    end
  end

end
