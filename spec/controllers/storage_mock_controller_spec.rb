require 'fog'
require 'spec_helper'

describe StorageMockController do
  it 'should upload a given image file locally' do
    post :upload_image, key: 'bird.jpeg', file: fixture_file_upload("files/bird.jpeg", 'image/jpeg')
    response.should be_success

    storage = Storage.new(:content_image)
    storage.read('bird.jpeg').should_not be_nil
  end
end