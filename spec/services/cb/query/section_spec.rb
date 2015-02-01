describe CB::Query::Section do

  let(:channel) { CB::Core::Channel.new }
  subject       { CB::Query::Section.new(channel) }

  describe '#list' do
    it 'returns all sections of the channel' do
      channel.stub(:sections).and_return(['two', 'sections'])
      subject.list.should eq ['two', 'sections']
    end
  end

  describe '#find_by_slug' do
    it 'returns the section of the channel with the given slug' do
      channel.stub(:sections).and_return double('sections', friendly: (friendly_double = double('friendly sections')))
      friendly_double.stub(:find).with('my slug').and_return('the_section')
      subject.find_by_slug('my slug').should eq([true, 'the_section'])
    end
  end
end