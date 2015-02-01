shared_examples_for "a channel who dynamically creates sections when publishing" do |channel_class|
  describe '#create_display_section_for_type_if_none' do
    before do
      @channel = channel_class.create!(name: 'My channel', url_prefix: 'my-new-chan')
      @content_type_double = double('content_type', id: 12, translated_title: 'A Content Type' )
    end

    it 'returns false if section in display mode exists for the given content_type' do
      existing_section = @channel.sections.create(title: 'my section', position: 0, mode: 'display', content_type_id: 12)

      @channel.create_display_section_for_type_if_none(@content_type_double).should be_false

      @channel.reload.sections.should eq [existing_section]
    end

    it 'returns true if section in display mode does not exist and is created' do
      section1 = @channel.sections.create(title: 'my section', position: 0, mode: 'display', content_type_id: 37)
      section2 = @channel.sections.create(title: 'my section', position: 1, mode: 'form', content_type_id: 12)

      @channel.create_display_section_for_type_if_none(@content_type_double).should be_true

      new_section = @channel.reload.sections.last

      new_section.title.should           eq 'A Content Type'
      new_section.position.should        eq 2
      new_section.mode.should            eq 'display'
      new_section.content_type_id.should eq 12
    end
  end
end