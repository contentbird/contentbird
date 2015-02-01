describe CB::Api::PaginatedResponse do
  let(:channel) { CB::Core::Channel.new }
  let(:result)  do
  	result_double = double('result')
  	result_double.stub(:page).with(2).and_return OpenStruct.new(some: 'data', current_page: 2, total_pages: 4)
  	result_double
  end
  subject { CB::Api::PaginatedResponse.new(channel, result, {context: 'sections', page: 2}) }

  describe '#response_headers' do
    it 'returns an empty hash' do
      subject.response_headers.should eq({'pagination-current' => 2, 'pagination-last' => 4})
    end
  end

  describe '#response_body' do
    it 'returns the result in a hash, and adds the channel sections if asked param as :context' do
      CB::Query::Section.stub(:new).with(channel).and_return double('section service', list: ['two', 'sections'])
      subject.response_body.should eq({ meta:     {current_page: 2, total_pages: 4},
      									result:   OpenStruct.new(some: 'data', current_page: 2, total_pages: 4),
                                        sections: ['two', 'sections'] })
    end
  end
end