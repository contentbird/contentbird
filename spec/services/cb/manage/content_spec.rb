require 'spec_helper'

describe CB::Manage::Content do
  let(:user)       { u = CB::Core::User.new ; u.id = 12; u }
  let(:book_type)  { FactoryGirl.build :book_type, owner: user }
  let(:dummy_type) { FactoryGirl.build :user_type, owner: user, id: 37 }
  subject { CB::Manage::Content.new(user) }

  describe '#initialize' do
    it 'stores the passed user' do
      subject.user.should eq user
    end
  end

  describe '#build_new' do
    it 'builds a new content of the given content_type and sets owner to the service user' do
      content = subject.build_new(dummy_type, {'properties' => {'some' => 'data'}})
      content.is_a?(CB::Core::Content).should be_true
      content.should_not be_persisted
      content.properties.should eq({'some' => 'data'})
      content.content_type.should eq dummy_type
      content.owner.should eq user
    end
  end

  describe '#recent_for_type' do
    it 'returns contents owned by the service user mathcing the given type and sorted by update recency' do
      CB::Core::Content.should_receive_in_any_order({owned_by: user}, {of_type: dummy_type}).should_receive(:recent).and_return ['recent', 'contents']
      subject.recent_for_type(dummy_type)
    end
  end

  describe '#recent' do
    it 'returns contents owned by the service user, including the types, and sorted by update recency' do
      CB::Core::Content.should_receive_in_any_order({owned_by: user}, {includes: :content_type}).should_receive(:recent).and_return ['recent', 'contents']
      subject.recent
    end
  end

  describe '#create' do
    before do
      @params = {'content' => 'properties'}
    end

    it 'creates a new content with the given params hash, set the content_type, saves it and returns it with success result' do
      subject.stub(:build_new).with(dummy_type, @params).and_return(content_double = double('content'))
      content_double.should_receive(:save).and_return true
      subject.create(dummy_type, @params).should eq [true, content_double]
    end

    it 'creates a new content_type with the given params hash, sets the owner tries saving it and returns it with failure result because save failed' do
      subject.stub(:build_new).with(dummy_type, @params).and_return(content_double = double('content'))
      content_double.should_receive(:save).and_return false
      subject.create(dummy_type, @params).should eq [false, content_double]
    end
  end

  describe '#find' do
    it 'returns the content owned by the service user AND matching the given id' do
      CB::Core::Content.stub(:owned_by).with(user).and_return(contents=double)
      contents.stub(:find).with('37').and_return('a content')
      subject.find('37').should eq 'a content'
    end
  end

  describe '#update' do
    before do
      @params = {'content' => 'params'}
    end
    it 'finds the content matching the given id, updates it with the given params hash and returns it with success result' do
      subject.stub(:find).with('37').and_return(content_double = double('content'))
      content_double.should_receive(:update_attributes).with(@params).and_return true
      subject.update('37', @params).should eq [true, content_double]
    end

    it 'finds the content matching the given id, update it with the given params hash and return it with failure result if update fails' do
      subject.stub(:find).with('37').and_return(content_double = double('content'))
      content_double.should_receive(:update_attributes).with(@params).and_return false
      subject.update('37', @params).should eq [false, content_double]
    end
  end

  describe '#destroy' do
    before do
      subject.stub(:find).with('37').and_return(@content = double('content', id: 42))
      @content.stub(:active_social_publications).and_return [ CB::Core::Publication.new(channel_id: 12, provider_ref: '12345'),
                                                              CB::Core::Publication.new(channel_id: 37, provider_ref: '54321') ]
    end
    context 'given it finds and destroys the content' do
      before do
        @content.should_receive(:destroy).and_return(true)
      end
      it 'enqueues the delete_contents_images and clean_social_publications jobs and returns the result and the content' do
        JobRunner.should_receive(:run).with(DeleteContentsImages, user.id, [@content.id])
        JobRunner.should_receive(:run).with(CleanSocialPublications, [[12, '12345'],[37, '54321']])
        subject.destroy('37').should eq [true, @content]
      end
    end
    context 'given it finds but fails while destroying the content' do
      before do
        @content.should_receive(:destroy).and_return(false)
      end
      it 'does not enqueue a delete_contents_images job and returns false and the content' do
        JobRunner.should_receive(:run).with(DeleteContentsImages, user.id, [@content.id]).never
        subject.destroy('37').should eq [false, @content]
      end
    end
  end

end