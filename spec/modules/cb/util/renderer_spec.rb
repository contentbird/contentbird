describe CB::Util::Renderer do

  subject {CB::Util::Renderer}

  describe '#render_template' do
    it 'looks for the given template in the api folder and render it passing params' do
      ActionView::Base.stub(:new)
                      .with('app/views', some: {nice: 'params'})
                      .and_return(erb_engine = double('erb'))

      erb_engine.stub(:render)
                .with(file: 'api/path/to/my_template')
                .and_return('html string')

      subject.render_template('path/to/my_template', some: {nice: 'params'}).should eq 'html string'
    end
  end
end