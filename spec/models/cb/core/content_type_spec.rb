require 'spec_helper'

describe CB::Core::ContentType do

  subject { CB::Core::ContentType.new(title: 'Simple Book', composite: false, title_label: 'Book title', owner_id: 37) }

  it 'persists and supports mass assignment' do
    subject.save!
    subject.reload
    subject.title.should                      eq 'Simple Book'
    subject.title_label.should                eq 'Book title'
    subject.name.should                       eq "simple-book_#{subject.id}"
    subject.composite.should                  be_false
    subject.usable_by_default.should          be_false
    subject.available_to_basic_users.should   eq true
    subject.owner_id.should                   eq 37
    subject.should_not                        be_by_platform
    subject.picto.should                      be_nil
  end

  it 'does not include ID in slug if the content type is "by_platform"' do
    subject.by_platform = true
    subject.save!
    subject.name.should eq 'simple-book'
  end

  it 'creates a content_type_usage for the type\'s owner when created' do
    subject.save!
    usage = CB::Core::ContentTypeUsage.last
    usage.content_type.should   eq subject
    usage.user_id.should eq     37
  end

  it { should have_many(:properties).class_name('CB::Core::ContentProperty').dependent(:destroy) }
  it { should have_many(:contents).class_name('CB::Core::Content').dependent(:destroy) }
  it { should have_many(:sections).class_name('CB::Core::Section').dependent(:destroy) }

  it { should belong_to(:owner).class_name('CB::Core::User') }
  it { should belong_to(:origin_type).class_name('CB::Core::ContentType') }

  it { should validate_presence_of :title }

  it { should accept_nested_attributes_for(:properties).allow_destroy(true) }

  it 'sorts its properties by position' do
    criteria = subject.properties.order_values.first
    criteria.class.should     eq Arel::Nodes::Ascending
    criteria.expr.name.should eq :position
  end

  describe 'virtual accessors' do
    it '#can_he_edit or #owned_by? returns true if the content_type owner id matches the given user \'s id' do
      user = CB::Core::User.new(id: 37)
      subject.can_he_edit?(user).should be_true
      subject.owned_by?(user).should be_true
      subject.owner_id = 12
      subject.can_he_edit?(user).should be_false
      subject.owned_by?(user).should be_false
    end
  end

  describe 'scopes' do
    it '#owned_by returns content_types owner_id matching passed user' do
      user = Struct.new(:id).new(12)
      criteria = CB::Core::ContentType.owned_by(user).where_values.first
      criteria.class.should     eq Arel::Nodes::Equality
      criteria.left.name.should eq 'owner_id'
      criteria.right.should     eq 12
    end

    it '#basic returns content_types with composite false' do
      criteria = CB::Core::ContentType.basic.where_values.first
      criteria.class.should     eq Arel::Nodes::Equality
      criteria.left.name.should eq 'composite'
      criteria.right.should     eq false
    end

    it '#usable_by_default returns content_types where usable_by_default is true' do
      criteria = CB::Core::ContentType.usable_by_default.where_values.first
      criteria.class.should     eq Arel::Nodes::Equality
      criteria.left.name.should eq 'usable_by_default'
      criteria.right.should     eq true
    end

    it '#with_owner eager loads the type\'s owner' do
      query = CB::Core::ContentType.with_owner
      query.includes_values.first.should eq :owner
    end
  end

  describe '#translated_title' do
    context 'given a content_type created by platform' do
      it 'returns the translated title' do
        I18n.stub(:t).with("content_type_name.shared").and_return 'Type partagé'
        FactoryGirl.build(:shared_type, name: 'shared').translated_title.should eq 'Type partagé'
      end
    end
    context 'given a content_type created by user' do
      it 'returns its title' do
        I18n.should_receive(:t).never
        FactoryGirl.build(:user_type).translated_title.should eq 'UserType'
      end
    end
  end

  describe '#properties_id_hash' do
    it 'returns a hash of properties where keys are names and values are ids' do
      article_type = FactoryGirl.create :article_type
      header = CB::Core::ContentProperty.find_by_name :header
      body   = CB::Core::ContentProperty.find_by_name :body

      article_type.properties_id_hash.should eq({'header' => header.id, 'body' => body.id})
    end
  end

end