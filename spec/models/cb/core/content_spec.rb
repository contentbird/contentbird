require 'spec_helper'
require 'cb/core/channel'

describe CB::Core::Content do

subject { CB::Core::Content.new }

  it 'should persist and support mass assignment and increment a counter cache on its content_type' do
    content_type = FactoryGirl.create :user_type
    content_type.contents_count.should eq 0

    content      = CB::Core::Content.create(title: 'Great Title', properties: {'some' => 'data'}, content_type_id: content_type.id, owner_id: content_type.owner_id)

    content.title.should            eq 'Great Title'
    content.properties.should       eq({'some' => 'data'})
    content.content_type_id.should  eq content_type.id
    content.owner_id.should         eq content_type.owner.id
    content.slug.should             eq 'great-title'

    content_type.reload.contents_count.should eq 1
  end

  describe 'associations' do
    it { should belong_to :content_type }
    it { should belong_to(:owner).class_name('CB::Core::User') }
    it { should have_many(:publications).dependent(:destroy) }
    it { should have_many(:published_channels).through(:publications) }
  end

  it { should validate_presence_of :title }
  it { should validate_presence_of :content_type_id }

  describe 'scopes' do
    it '#owned_by returns contents with owner_id matching passed user' do
      user = Struct.new(:id).new(12)
      criteria = CB::Core::Content.owned_by(user).where_values.first
      criteria.class.should     eq Arel::Nodes::Equality
      criteria.left.name.should eq 'owner_id'
      criteria.right.should     eq 12
    end

    it '#of_type returns contents of the given content_type' do
      type = Struct.new(:id).new(12)
      criteria = CB::Core::Content.of_type(type).where_values.first
      criteria.class.should     eq Arel::Nodes::Equality
      criteria.left.name.should eq 'content_type_id'
      criteria.right.should     eq 12
    end

    it '#recent sorts the contents by updated_at DESC' do
      CB::Core::Content.recent.order_values.should eq ['updated_at DESC']
    end

    it '#published_on_channel only returns contents with a publication on the given channel' do
      query = CB::Core::Content.published_on_channel(OpenStruct.new(id: 43))
      query.joins_values.first.should eq :publications
      query.where_values.first.should eq 'publications.channel_id = 43'
    end

    it '#search_on_title returns contents matching the given search string' do
      query = CB::Core::Content.search_on_title('my string')
      query.where_values.first.should eq "title @@ 'my string'"
    end
  end

  describe 'virtual accessors' do
    it '#publications_by_channel returns its publications placed in a hash which key is the publication channel_id' do
      subject.stub(:publications).and_return([
                                              pub1 = OpenStruct.new(channel_id: 37),
                                              pub2 = OpenStruct.new(channel_id: 42)
                                            ])
      subject.publications_by_channel.should eq({'37' => pub1, '42' => pub2})
    end

    it '#exportable_properties returns the fields hash including the content_type name on each field' do
      book = FactoryGirl.create(:book_content)
      book.exportable_properties.should eq({  'author' => {'title' => 'Author', 'value' => 'my author', 'type' => 'text', 'i18n' => false},
                                              'summary' => {'title' => 'Summary', 'value' => 'my summary', 'type' => 'memo', 'i18n' => false},
                                              'image' => {'title' => 'Image', 'value' => '/app/storage_mock/image/my_image.png', 'type' => 'image', 'i18n' => false}
                                            })

      book.content_type.by_platform = true
      book.set_exportable_properties #because exportable properties is memoized, heh :)
      book.exportable_properties.should eq({  'author' => {'title' => "translation missing: test.content_type_properties_name.#{book.content_type.name}.author", 'value' => 'my author', 'type' => 'text', 'i18n' => true},
                                              'summary' => {'title' => "translation missing: test.content_type_properties_name.#{book.content_type.name}.summary", 'value' => 'my summary', 'type' => 'memo', 'i18n' => true},
                                              'image' => {'title' => "translation missing: test.content_type_properties_name.#{book.content_type.name}.image", 'value' => '/app/storage_mock/image/my_image.png', 'type' => 'image', 'i18n' => true}
                                            })
      book.content_type.by_platform = false
      book.update_attributes(properties: nil)
      book.exportable_properties.should eq({  'author' => {'title' => 'Author', 'value' => nil, 'type' => 'text', 'i18n' => false},
                                              'summary' => {'title' => 'Summary', 'value' => nil, 'type' => 'memo', 'i18n' => false},
                                              'image' => {'title' => 'Image', 'value' => nil, 'type' => 'image', 'i18n' => false}
                                            })
    end

    describe '#first_image_property and #first_image_property_key' do

      context 'Given a content with no image property' do
        before do
          @article = FactoryGirl.create(:article_content)
        end
        it 'returns nil' do
          @article.first_image_property_key.should  be_nil
          @article.first_image_property.should      be_nil
          @article.first_image_property_url.should  be_nil
        end
      end

      context 'Given a content with 1 gallery and 1 image properties' do
        before do
          @gallery = FactoryGirl.create(:gallery_content)
        end
        it 'returns the thumbnail url of the first image of the gallery' do
          @gallery.first_image_property_key.should  eq("images")
          @gallery.first_image_property.should      eq({"title" => "translation missing: test.content_type_properties_name.gallery.images",
                                                        "value" => [{"url"=>"/app/storage_mock/image/gal/photo1.png", "legend"=>"la photo 1"}, {"url"=>"/app/storage_mock/image/gal/photo2.jpg", "legend"=>"la photo 2"}],
                                                        "type"  => "image_gallery",
                                                        "i18n"  => true})
          @gallery.first_image_property_url.should  eq('/app/storage_mock/image/gal/photo1_thumb.jpg')
        end
      end

      context 'Given a content with 1 url and 1 image properties' do
        before do
          @link_with_image = FactoryGirl.create(:link_content_with_image)
        end
        it 'returns the thumbnail url of the image property of the content' do
          @link_with_image.first_image_property_key.should  eq("thumbnail")
          @link_with_image.first_image_property.should      eq({"title" => "translation missing: test.content_type_properties_name.link.thumbnail",
                                                                "value" => "/app/storage_mock/image/img/1.jpg",
                                                                "type"  => "image",
                                                                "i18n"  => true})
          @link_with_image.first_image_property_url.should  eq('/app/storage_mock/image/img/1_thumb.jpg')
        end
      end

      context 'Given a content with 1 url and no image properties' do
        before do
          CB::Core::Media.stub(:image_for_url).with('https://youtube.com/watch?v=1234567').and_return('//img.youtube.com/vi/1234567/2.jpg')
          @link_without_image = FactoryGirl.create(:link_content)
        end
        it 'returns the value of the image property of the content' do
          @link_without_image.first_image_property_key.should  eq("link")
          @link_without_image.first_image_property.should      eq({"title"  => "translation missing: test.content_type_properties_name.link.link",
                                                                "value"     => "https://youtube.com/watch?v=1234567",
                                                                "type"      => "url",
                                                                "i18n"      => true})
          @link_without_image.first_image_property_url.should  eq('//img.youtube.com/vi/1234567/2.jpg')
        end
      end

    end

    describe '#first_textual_property and #first_textual_property_key' do
      let(:book) { CB::Core::Content.new }

      context 'Given a content with 2 text or memo properties' do
        before do
          book.stub(:exportable_properties).and_return({'summary' => {'title' => 'Summary', 'value' => 'my summary', 'type' => 'memo'},
                                                        'author'  => {'title' => 'Author', 'value' => 'the author', 'type' => 'text'},
                                                        'comment' => {'title' => 'Comment', 'value' => 'I like it', 'type' => 'memo'}})
        end
        it 'returns the value of the first text or memo of the content' do
          book.first_textual_property_key.should  eq 'summary'
          book.first_textual_property.should      eq({"title"=>"Summary", "value"=>"my summary", "type"=>"memo"})
        end
      end

      context 'Given a content with no text nor memo property' do
        before do
          book.stub(:exportable_properties).and_return({'cover' => {'title' => 'Cover', 'value' => '/app/storage_mock/image/my_image', 'type' => 'image'}})
        end
        it 'returns nil' do
          book.first_textual_property_key.should  be_nil
          book.first_textual_property.should      be_nil
        end
      end
    end

    describe '#active_social_publications' do
      it 'returns its publications with a provider_ref' do
        subject.stub(:publications).and_return [pub1 = OpenStruct.new(provider_ref: ''),
                                                pub2 = OpenStruct.new(provider_ref: '1234'),
                                                pub3 = OpenStruct.new(provider_ref: nil)]
        subject.active_social_publications.should eq [pub2]
      end
    end

  end

  describe 'slug changes propagation to website publication url alias' do
    it 'copies the slug value to its website publications everytime it changes' do
      content = FactoryGirl.create(:book_content, title: 'Great title')

      website_channel = CB::Core::WebsiteChannel.create!(owner_id: 42, name: "my_site", url_prefix: 'site')
      social_channel = CB::Core::SocialChannel.create!(owner_id: 42, provider: 'twitter', name: "twitter", url_prefix: 't')

      website_publication = content.publications.create!(channel_id: website_channel.id)
      social_publication  = content.publications.create!(channel_id: social_channel.id)

      content.update_attributes(title: "new title")

      social_publication.reload.url_alias.should_not eq "new-title"
      website_publication.reload.url_alias.should    eq "new-title"
    end
  end
end