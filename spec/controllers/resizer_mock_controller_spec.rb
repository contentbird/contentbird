require 'spec_helper'
require 'RMagick'

describe ResizerMockController do

  describe '#resize_image' do
    it 'read the temporary file, and resize it to 400x400 px and save it in jpeg format' do
      Storage.stub(:new).with(:content_image).and_return(storage_mock = double('content_image'))
      storage_mock.stub(:url).with('my_tmp_image_thumb.jpg').and_return('http://images.cb.com/my_tmp_image_thumb.jpg')
      Magick::ImageList.stub(:new).and_return(image_mock = double('new image'))
      storage_mock.should_receive(:read).with('my_tmp_image.gif').and_return(image_stream = double('image_stream'))
      image_mock.should_receive(:from_blob).with(image_stream)
      image_mock.should_receive(:resize_to_fit).with(400, 400).and_return(reduced_image = double('reduced image'))
      reduced_image.should_receive(:format=).with('JPG')
      reduced_image.stub(:to_blob).and_return(image_blob = double('image blob'))
      reduced_image.stub(:columns).and_return(400)
      reduced_image.stub(:rows).and_return(300)
      storage_mock.should_receive(:write).with('my_tmp_image_thumb.jpg', image_blob).and_return(saved_file = double('saved file', key: 'my_tmp_image_thumb.jpg'))

      Kernel::silence_warnings do
        get :resize_image, image: 'my_tmp_image.gif', callback: 'jsonp1234'
      end

      response.body.should eq('jsonp1234({"key":"my_tmp_image_thumb.jpg","width":400,"height":300})')

    end

    it 'returns a status 200 and store the error in the response body if anything wrong happens' do
      Kernel::silence_warnings do
        get :resize_image, image: 'not_found.gif', callback: 'jsonp1234'
      end
      JSON.parse(response.body)['error'].should_not be_nil
    end
  end

end