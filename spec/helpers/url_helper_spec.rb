require 'spec_helper'

describe UrlHelper do
  describe '#media_url' do
    it "returns the full url of a media, knowing it's type and its path, using the storage conf" do
      with_constants(:STORAGE => { content_some_type: { url: 'http://some.url.org/toto' } }) do
        media_url(:some_type, 'folder/1234_123.jpg').should eq 'http://some.url.org/toto/folder/1234_123.jpg'
        media_url(:some_type).should eq 'http://some.url.org/toto/'
      end
    end
  end
  describe '#channel_media_url' do
    it "returns the full url of a channel cover, knowing it's type and its path, using the storage conf" do
      with_constants(:STORAGE => { channel_media: { url: 'http://some.url.org/toto' } }) do
        channel_media_url(:cover, '1234_123.jpg').should eq 'http://some.url.org/toto/1234_123.jpg'
        channel_media_url(:cover).should eq 'http://some.url.org/toto/'
      end
    end
  end
end