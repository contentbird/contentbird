describe CB::Core::SectionSerializer do

  let(:section) { s = CB::Core::Section.new(title: 'Read my great blog', forewords: "this is long,\n keep up!") ; s.id = 37 ; s}
  subject       { CB::Core::SectionSerializer.new(section) }

  describe '#to_json' do
    it 'returns a well formatted json' do
      subject.to_json.should eq({ id: section.id,
                                  slug: section.slug,
                                  title: section.title,
                                  mode: section.mode,
                                  forewords: section.forewords }.to_json)
    end
  end
end