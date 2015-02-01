describe CB::Core::ContentSerializer do

  let(:book) { FactoryGirl.create(:book_content)}
  subject    { CB::Core::ContentSerializer.new(book) }

  describe '#to_json' do
    it 'returns a well formatted json' do
      subject.to_json.should eq({ id: book.id,
                                  type: book.content_type.name,
                                  title: book.title,
                                  slug: book.slug,
                                  properties: book.exportable_properties}.to_json)
    end

    it 'includes activerecord errors if needed' do
      book.title = nil
      book.save
      subject.to_json.should eq({ id: book.id,
                                  type: book.content_type.name,
                                  title: book.title,
                                  slug: book.slug,
                                  properties: book.exportable_properties,
                                  errors: {"title" => [I18n.t('activerecord.errors.models.cb/core/content.attributes.title.blank')]} }.to_json)
    end
  end
end