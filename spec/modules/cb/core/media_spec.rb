require 'spec_helper'

describe CB::Core::Media do

  subject {CB::Core::Media}

  describe '#media_url' do
    it 'concatenates matching storage conf url and with given path' do
      with_constants(:STORAGE => { content_some_type: { url: 'http://some.url.org/toto' } }) do
        subject.media_url(:some_type, 'path/to/my_file.jpg').should eq 'http://some.url.org/toto/path/to/my_file.jpg'
      end
    end
  end
  describe '#image_for_url' do
    context 'given a youtube video url' do
      it { subject.image_for_url('https://youtube.com/watch?v=1234567').should eq '//img.youtube.com/vi/1234567/0.jpg'}
    end
    context 'given a dailymotion video url' do
      it { subject.image_for_url('http://www.dailymotion.com/video/x1965v5_le-billet-de-francois-morel-plonk-et-replonk_fun').should eq '//www.dailymotion.com/thumbnail/video/x1965v5'}
    end
    context 'given a non recognized url' do
      it { subject.image_for_url('http://my-pretty-site.com/unicorns?color=pink').should be_nil}
    end
    context 'given a soundcloud, spotify, vimeo or deezer url' do
      it 'should infer a static thumbnail name' do
        subject.image_for_url('http://vimeo.com/89503262').should eq '//example.com/link-images/vimeo.jpg'
        subject.image_for_url('http://open.spotify.com/track/20OgHXJcrRR9OnUlDkGqEM').should eq '//example.com/link-images/spotify.jpg'
        subject.image_for_url('http://www.deezer.com/track/3129749').should eq '//example.com/link-images/deezer.jpg'
        subject.image_for_url('https://soundcloud.com/larusso/puente-subida-showtek-booyah').should eq '//example.com/link-images/soundcloud.jpg'
      end
    end
  end

end