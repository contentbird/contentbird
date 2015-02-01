require 'spec_helper'

describe CB::Core::ContentProperty do
  let(:image_property) {p= CB::Core::ContentProperty.new(name: 'cover') ; p.stub(:content_type).and_return(OpenStruct.new(name: 'image')) ; p}
  let(:image_gallery_property) {p= CB::Core::ContentProperty.new(name: 'gallery') ; p.stub(:content_type).and_return(OpenStruct.new(name: 'image_gallery')) ; p}
  let(:text_property)  {p= CB::Core::ContentProperty.new(name: 'resume') ; p.stub(:content_type).and_return(OpenStruct.new(name: 'text')) ; p}

  it 'should persist and support mass assignment' do
    type = CB::Core::ContentProperty.create(title: 'My New Title', position: 1, father_type_id: 12, content_type_id: 37)
    type.reload

    type.title.should           eq 'My New Title'
    type.name.should            eq 'my-new-title'
    type.position.should        eq 1
    type.father_type_id.should  eq 12
    type.content_type_id.should eq 37
  end

  it { should belong_to :content_type }
  it { should belong_to :father_type }

  it { should validate_presence_of :title }
  it { should validate_presence_of :position }
  it { should validate_presence_of :content_type_id }

  it { should validate_numericality_of :position }

  describe '#export_value' do
    context 'given a unique media' do
      it 'returns url instead of path if property is a media' do
        CB::Core::Media.stub(:media_url).with(:image, 'myfile.jpg').and_return('http://my.storage.net/folder/myfile.jpg')
        CB::Core::Media.stub(:media_url).with(:image, nil).and_return('i should not be called')

        image_property.export_value('myfile.jpg').should eq 'http://my.storage.net/folder/myfile.jpg'
        image_property.export_value(nil).should eq nil
      end
    end

    context 'given an array medias (gallery for instance)' do
      it 'returns url for all values of keys named url' do
        CB::Core::Media.stub(:media_url).with(:image_gallery, 'myfile.jpg').and_return('http://my.storage.net/folder/myfile.jpg')
        CB::Core::Media.stub(:media_url).with(:image_gallery, 'myfile2.jpg').and_return('http://my.storage.net/folder/myfile2.jpg')

        image_gallery_property.export_value([{'url' => 'myfile.jpg', 'comment' => 'some comment'}, {'key' => 'value', 'other_key' => 'other_value', 'url' => 'myfile2.jpg'}])
                               .should   eq([{"url"=>"http://my.storage.net/folder/myfile.jpg", "comment"=>"some comment"}, {"key"=>"value", "other_key"=>"other_value", "url"=>"http://my.storage.net/folder/myfile2.jpg"}])
      end
    end

    context 'given property is not a media' do
      before do
        @prop = CB::Core::ContentProperty.new
        @prop.stub(:media?).and_return(false)
      end
      it 'returns the given value' do
        @prop.export_value('some value').should eq 'some value'
      end
    end
  end

  describe '#media?' do
    it 'returns true if its content_type is named image or image_gallery, and false otherwise' do
      image_property.should         be_media
      image_gallery_property.should be_media
      text_property.should_not      be_media
    end
  end

  describe '#translated_title' do
    context 'given a content_type created by platform and containing a property' do
      it 'returns the translated title using the content type name and the property name as a translation key' do
        post_type = FactoryGirl.create(:post_type)
        post_type.properties.first.translated_title(post_type).should eq 'translation missing: test.content_type_properties_name.blog.body'
        post_type.properties.first.translated_title.should            eq 'translation missing: test.content_type_properties_name.blog.body'
      end
    end
    context 'given a content_type created by user' do
      it 'returns its title' do
        post_type = FactoryGirl.create(:article_type)
        post_type.properties.first.translated_title(post_type).should eq 'header'
        post_type.properties.first.translated_title.should            eq 'header'
      end
    end
  end

end