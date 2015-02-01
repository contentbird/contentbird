describe CB::Query::Publication do

  let(:channel) { CB::Core::Channel.new }
  subject       { CB::Query::Publication.new(channel) }

  describe '#list' do
    it 'returns all publications in the channel' do
      publications = CB::Core::Publication.should_receive_in_any_order( {from_channel: channel}, :with_content_and_type, :recent)
      subject.list.should eq [true, publications]
    end
    context 'given the channel is social and doesn\'t allow a content feed' do
      before do
        channel.allow_social_feed = false
        channel.stub(:social?).and_return true
      end
      it 'returns false and raise a not found exception' do
         expect{subject.list}.to raise_error(ActiveRecord::RecordNotFound, 'The user does not wish to list his publications feed')
      end
    end
  end

  describe '#list_for_section' do
    it 'returns publications in the given section' do
      publications = CB::Core::Publication.should_receive_in_any_order( {from_channel: channel},
                                                                {of_content_type: 17},
                                                                :with_content_and_type,
                                                                :recent)
      subject.list_for_section(OpenStruct.new(content_type_id: 17)).should eq [true, publications]
    end
    it 'returns false and a not found message if no section given' do
      subject.list_for_section(nil).should eq [false, {error: :not_found, message: 'Section not found on this channel'}]
    end
  end

  describe '#list_for_home' do
    it 'returns all publications in the channel home_section' do
      channel.stub(:home_section).and_return(section = OpenStruct.new(id: 12))
      subject.stub(:list_for_section).with(section).and_return ['two', 'publications']

      subject.list_for_home.should eq ['two', 'publications']
    end
  end

  describe '#list_for_section_slug' do
    it 'returns all publications in the section with given slug' do
      CB::Query::Section.stub(:new).with(channel).and_return(section_service = double('section service'))
      section_service.stub(:find_by_slug).with('my_section_slug').and_return([true, section = OpenStruct.new(id: 12)])
      subject.stub(:list_for_section).with(section).and_return ['two', 'publications']

      subject.list_for_section_slug('my_section_slug').should eq ['two', 'publications']
    end
  end

  describe '#find_by_slug_and_section_slug' do
    before do
      CB::Query::Section.stub(:new).with(channel).and_return(section_service = double('section service'))
      section_service.stub(:find_by_slug).with('my_section_slug')
                                         .and_return([true, section = OpenStruct.new(id: 12, content_type_id: 17)])
    end
    it 'returns the content matching the given slug AND published in the section matching the given section slug' do
      CB::Core::Publication.should_receive_in_any_order({from_channel: channel},
                                                        {of_content_type: 17},
                                                        :with_content_and_type,
                                                        {with_url_alias: 'my-content-slug'}).stub(:first)
                                                                                            .and_return('the content')
      subject.find_by_slug_and_section_slug('my-content-slug', 'my_section_slug').should eq [true, 'the content']
    end
    context 'given no publication matches the given content-slug' do
      before do
        CB::Core::Publication.should_receive_in_any_order({from_channel: channel},
                                                          {of_content_type: 17},
                                                          :with_content_and_type,
                                                          {with_url_alias: 'non-existing-slug'}).stub(:first)
                                                                                              .and_return(nil)
      end
      it 'returns a splat with false and error' do
        subject.find_by_slug_and_section_slug('non-existing-slug', 'my_section_slug').should eq [false, {error: :not_found, message: 'Publication not found'}]
      end
    end
  end

  describe '#find_by_url_alias' do
    it 'returns the content published on given channel where publication_url_alias matches given url_alias' do
      CB::Core::Publication.should_receive_in_any_order({from_channel: channel},
                                                    {with_url_alias: 'my-alias'},
                                                    :with_content_and_type
                                                    ).stub(:first).and_return('the publication')

      subject.find_by_url_alias('my-alias').should eq [true, 'the publication']
    end
    context 'given no publication matches the given url_alias' do
      before do
        CB::Core::Publication.should_receive_in_any_order({from_channel: channel},
                                                    {with_url_alias: 'unknown-alias'},
                                                    :with_content_and_type
                                                    ).stub(:first).and_return(nil)
      end
      it 'returns a splat with false and an error' do
        subject.find_by_url_alias('unknown-alias').should eq [false, {error: :not_found, message: 'Publication not found'}]
      end
    end
  end
end