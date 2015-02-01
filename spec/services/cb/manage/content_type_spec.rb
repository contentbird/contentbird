require 'spec_helper'

describe CB::Manage::ContentType do
  let(:user) {u = FactoryGirl.build(:user) ; u.id = 12; u}
  subject { CB::Manage::ContentType.new(user) }

  describe '#initialize' do
    it 'stores the passed user' do
      subject.user.should eq user
    end
  end

  describe '#build_forked_type' do
    it 'duplicates the given content_type and sets owner to the service user' do
      book        = FactoryGirl.create :book_type, usable_by_default: true

      forked_book = subject.build_forked_type book

      forked_book.should_not be_persisted

      forked_book.should_not be_usable_by_default
      forked_book.owner.should eq user
      forked_book.origin_type.should eq book
      forked_book.properties.each {|prop| prop.should_not be_persisted}
      forked_book.properties.map(&:meaningful_attributes).should eq book.properties.map(&:meaningful_attributes)
    end
  end

  describe '#fork_type' do
    it 'duplicates the given content_type and sets owner to the service user' do
      user.id = nil
      user.save

      book        = FactoryGirl.create :book_type

      forked_book = subject.fork_type book

      forked_book.should be_persisted
      forked_book.reload
      #forked_book.name.should eq book.name
      forked_book.title.should eq book.title
      forked_book.owner.should eq user
      forked_book.origin_type.should eq book
      forked_book.properties.each {|prop| prop.should be_persisted}
      forked_book.properties.map{|p| p.meaningful_attributes(['father_type_id', 'name'])}.should eq book.properties.map{|p| p.meaningful_attributes(['father_type_id', 'name'])}
      forked_book.id.should_not eq book.id
    end
  end

  describe '#user_made_types' do
    it 'returns the content types owned by the service user' do
      CB::Core::ContentType.stub(:owned_by).with(user).and_return(['my', 'own', 'types'])
      subject.user_made_types.should eq ['my', 'own', 'types']
    end
  end

  describe '#selectable_types' do
    it 'returns all non composite content_types' do
      CB::Core::ContentType.stub(:basic).and_return(['basic', 'types'])
      subject.selectable_types.should eq ['basic', 'types']
    end
  end

  describe '#user_types' do
    it 'returns the content types owned or usable_by the service user' do
      user.stub(:content_types).and_return(['user', 'types'])
      subject.user_types.should eq ['user', 'types']
    end
  end

  describe '#find' do
    it 'returns the content_type owned by or shared with the service user AND matching the given id' do
      user.stub(:content_types).and_return(types=double)
      types.stub(:find).with('37').and_return('a type')
      subject.find('37').should eq 'a type'
    end
  end

  describe '#find_own' do
    it 'returns the content_type owned by the service user AND matching the given id' do
      CB::Core::ContentType.stub(:owned_by).with(user).and_return(types=double)
      types.stub(:find).with('37').and_return('a type')
      subject.find_own('37').should eq 'a type'
    end
  end

  describe '#build_new' do
    it 'returns a new content_type, passing optional params to the new method' do
      CB::Core::ContentType.stub(:new).with({}).and_return('a type')
      CB::Core::ContentType.stub(:new).with({some: 'params'}).and_return('a pre-filled type')

      subject.build_new.should eq 'a type'
      subject.build_new({some: 'params'}).should eq 'a pre-filled type'
    end
  end

  describe '#update' do
    before do
      @params = {'type' => 'params'}
      subject.stub(:find_own).with('37').and_return(@type_double = double('type', id: 37, contents_count: 2))
    end

    it 'finds the type matching the given id, updates it with the given params hash, enqueues the propagate_properties_changes job and returns it with success result' do
      @type_double.should_receive(:update_attributes).with(@params).and_return true
      JobRunner.should_receive(:run).with(PropagatePropertiesChanges, @type_double.id)
      subject.update('37', @params).should eq [true, @type_double]
    end

    it 'does not enqueue the propagate_properties_changes job if update was succesful BUT the type has no content' do
      @type_double.stub(:contents_count).and_return 0
      @type_double.should_receive(:update_attributes).with(@params).and_return true
      JobRunner.should_receive(:run).with(PropagatePropertiesChanges, @type_double.id).never
      subject.update('37', @params).should eq [true, @type_double]
    end

    it 'should find the type matching the given id, update it with the given params hash and return it with failure result if update fails' do
      @type_double.should_receive(:update_attributes).with(@params).and_return false
      JobRunner.should_receive(:run).with(PropagatePropertiesChanges, @type_double.id).never
      subject.update('37', @params).should eq [false, @type_double]
    end
  end

  describe '#create' do
    before do
      @params = {'type' => 'params'}
    end
    it 'creates a new content_type with the given params hash, set the owner, saves it and returns it with success result' do
      subject.stub(:build_new).with(@params).and_return(type_double = double('type'))
      type_double.should_receive(:owner=).with(user)
      type_double.should_receive(:by_platform=).with(false)
      type_double.should_receive(:save).and_return true
      subject.create(@params).should eq [true, type_double]
    end

    it 'sets the type as "by_platform" if the owner is a "platform_user"' do
      user.platform_user = true
      subject.stub(:build_new).with(@params).and_return(type_double = double('type'))
      type_double.should_receive(:owner=).with(user)
      type_double.should_receive(:by_platform=).with(true)
      type_double.should_receive(:save).and_return true
      subject.create(@params).should eq [true, type_double]
    end

    it 'creates a new content_type with the given params hash, sets the owner tries saving it and returns it with failure result because save failed' do
      subject.stub(:build_new).with(@params).and_return(type_double = double('type'))
      type_double.should_receive(:owner=).with(user)
      type_double.should_receive(:by_platform=).with(false)
      type_double.should_receive(:save).and_return false
      subject.create(@params).should eq [false, type_double]
    end
  end

  describe '#destroy' do
    context 'given it finds and destroys the content type' do
      before do
        subject.stub(:find_own).with('37').and_return(@type_double = double('type', content_ids: [1, 8, 34]))
        @type_double.should_receive(:destroy).and_return(true)
      end
      it 'enqueues the delete_contents_images job for all its contents ids, and returns the result and the content_type' do
        JobRunner.should_receive(:run).with(DeleteContentsImages, user.id, @type_double.content_ids)
        subject.destroy('37').should eq [true, @type_double]
      end
    end
    context 'given it finds but fails while destroying the content type' do
      before do
        subject.stub(:find_own).with('37').and_return(@type_double = double('type', content_ids: [1, 8, 34]))
        @type_double.should_receive(:destroy).and_return(false)
      end
      it 'does not enqueue the delete_contents_images job and returns false and the content_type' do
        JobRunner.should_receive(:run).with(DeleteContentsImages, user.id, @type_double.content_ids).never
        subject.destroy('37').should eq [false, @type_double]
      end
    end
  end
end