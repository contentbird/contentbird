class ResizerMockController < ApplicationController

  def resize_image
    require 'RMagick'
    storage = Storage.new(:content_image)
    image_stream = storage.read(params[:image])
    image = Magick::ImageList.new()
    image.from_blob(image_stream)
    resized_image = image.resize_to_fit(400, 400)
    resized_image.format = 'JPG'
    resized_image_name = params[:image].split('.').first + '_thumb.jpg'
    saved_image = storage.write(resized_image_name, resized_image.to_blob)

    render  json: { key:    saved_image.key,
                    width:  resized_image.columns,
                    height: resized_image.rows    },
            callback: params[:callback]
    rescue => e
      render  json: { error: e.message }
  end
end