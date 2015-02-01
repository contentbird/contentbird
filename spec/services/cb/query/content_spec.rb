describe CB::Query::Content do

  let(:channel) { CB::Core::Channel.new(owner_id: 37) }
  subject       { CB::Query::Content.new(channel) }

  before do
    CB::Query::Section.stub(:new).with(channel).and_return(section_service = double('section service'))
    section_service.stub(:find_by_slug).with('my-section-slug').and_return([true, OpenStruct.new(content_type: 'content-type')])
  end

  describe '#new_for_section_slug' do
    it 'returns a new Content of the given section\'s content_type' do
      subject.stub(:properties_keys_from_names_to_ids).with({some: 'data'}, 'content-type')
                                                      .and_return({cleaned: 'attrs'})

      CB::Core::Content.stub(:new).with({content_type: 'content-type', owner_id: 37, cleaned: 'attrs'})
                                  .and_return('new content')

      subject.new_for_section_slug('my-section-slug', some: 'data').should eq [true, 'new content']
    end
  end

  describe '#create_for_section_slug' do
    it 'saves and returns a new content of the given section\'s content_type' do
      subject.stub(:new_for_section_slug).with('my-section-slug', some: 'data')
                                  .and_return([true, content_double = double('new content', save: true)])

      subject.create_for_section_slug('my-section-slug', some: 'data').should eq [true, content_double]
    end

    it 'returns false and the invalid content object if the content save failed' do
      subject.stub(:new_for_section_slug).with('my-section-slug', some: 'data')
                                  .and_return([true, content_double = double('new content', save: false)])

      subject.create_for_section_slug('my-section-slug', some: 'data').should eq [false, content_double]
    end
  end

  describe '#properties_keys_from_names_to_ids' do
    it 'replaces the properties hash keys with the given content type properties ids' do
      params = {title: 'My Content', properties: {'author' => 'My Author', 'summary' => 'My Summary'}}
      book_type = FactoryGirl.create(:book_type)
      cleaned_params = {title: 'My Content', properties: {book_type.properties[0].id.to_s => 'My Author',
                                                          book_type.properties[1].id.to_s => 'My Summary',
                                                          book_type.properties[2].id.to_s => nil
                                                        }}

      subject.send(:properties_keys_from_names_to_ids, params, book_type).should eq cleaned_params
    end
  end
end