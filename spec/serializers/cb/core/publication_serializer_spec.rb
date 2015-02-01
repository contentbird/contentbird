describe CB::Core::PublicationSerializer do

  let(:book) { FactoryGirl.create(:book_content)}
  let(:publication) { book.publications.create!(channel_id: 10, url_alias: 'my-alias') }
  subject    { CB::Core::PublicationSerializer.new(publication) }

  describe '#to_json' do
    it 'returns a well formatted json' do
      freeze_time
      subject.to_json.should eq({ published_at: publication.created_at,
                                  type: book.content_type.name,
                                  title: book.title,
                                  slug: 'my-alias',
                                  first_image: 'image',
                                  thumbnail: '/app/storage_mock/image/my_image_thumb.jpg',
                                  first_text: 'author',
                                  properties: book.exportable_properties}.to_json)
    end
  end
end