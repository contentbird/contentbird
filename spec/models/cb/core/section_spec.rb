require 'spec_helper'

describe CB::Core::Section do
  subject {CB::Core::Section.new}

  it 'persists and supports mass assignment' do
    attrs = { title: 'Read my great blog',
              position: 2,
              channel_id: 37,
              content_type_id: 42,
              mode: 'display',
              forewords: "This section is legen\n...wait for it...\n...dary! Legendary!" }

    section = CB::Core::Section.create(attrs)
    section.reload

    section.meaningful_attributes.should   eq attrs.stringify_keys.merge({'slug' => 'read-my-great-blog'})
  end

  describe 'validations' do
    it { should validate_presence_of   :title }
    it { should validate_presence_of   :position }
    it { should validate_presence_of   :mode }
    it { should validate_presence_of   :content_type_id }
  end

  describe 'relations' do
    it { should belong_to(:channel).class_name('CB::Core::Channel') }
    it { should belong_to(:content_type).class_name('CB::Core::ContentType') }
  end

end