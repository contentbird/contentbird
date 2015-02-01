require 'fileutils'

class StorageMockController < ApplicationController
    before_filter { redirect_to(root_path) if Rails.env.production? }
    protect_from_forgery except: :upload_image

  def upload_image
    upload :content_image
  end

  def download_image
    name = params[:key]
    download :content_image, name, '.jpg', "image/jpeg"
  end

  def upload_css
    #implement if needed
  end

  def download_css
    download :channel_media, "css/#{params[:channel_id]}/#{params[:key]}", '.css', "text/css"
  end


  def upload storage
    file = params[:file]
    name = params[:key]
    s = Storage.new(storage)
    path = "#{s.local_root}/#{s.directory}/#{name}"

    dirname = File.dirname(path)
    FileUtils.mkdir_p(dirname) unless File.directory?(dirname)

    File.open(path, "wb") { |f| f.write(file.read) }

    #(render status: 500) if File.size(path) > s.max_size

    render nothing: true
  end

  def download storage, name, extension, mime
    s = Storage.new(storage)
    path = "#{s.local_root}/#{s.directory}/#{name}"

    content = File.read(path)

    render text: content, content_type: mime, content_disposition: 'inline'
  end

end