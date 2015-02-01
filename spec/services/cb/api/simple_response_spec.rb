describe CB::Api::SimpleResponse do
  let(:channel) { CB::Core::Channel.new }
  subject       { CB::Api::SimpleResponse.new(channel, {some: 'result'}, {context: 'sections,channel', page: 2}) }

  describe '#response_headers' do
    it 'returns an empty hash' do
      subject.response_headers.should eq({})
    end
  end

  describe '#response_body' do
    before do
      CB::Query::Section.stub(:new).with(channel).and_return double('section service', list: ['two', 'sections'])
      channel.stub(:css).and_return(OpenStruct.new(url: 'path/to/channel_css.css'))
    end

    it 'returns the result in a hash, and adds the channel sections if asked param as :context' do
      subject.response_body.should eq({ result:   {some: 'result'},
                                        sections: ['two', 'sections'],
                                        channel:  channel })
    end

    it 'renders an html template with the result object if context includes "html"' do
      CB::Util::Renderer.stub(:render_template)
                        .with('contents/_form', content: {some: 'result'})
                        .and_return("html <form action=\"\"> <!-- begin_cut_zone -->with \n fields<!-- end_cut_zone --> </form> and buttons")

      simple_response = CB::Api::SimpleResponse.new(channel, {some: 'result'}, {context: 'sections,html'})


      simple_response.response_body.should eq({ result:   {some: 'result'},
                                                sections: ['two', 'sections'],
                                                html:     "with \n fields" })
    end
  end

end