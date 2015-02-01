require 'spec_helper'

describe DeleteUser do
  describe "do_perform" do
    context 'given a user using 3 content types, having created a few contents in each of them' do
      before do
        @user = double('user', id: 37)
        @user.stub(:content_types).and_return([@type1 = double('content type 1'), @type2 = double('content type 2'), @type3 = double('empty type')])
        CB::Manage::Content.stub(:new).with(@user).and_return(@service = double('content service'))
        @service.stub(:recent_for_type).with(@type1).and_return(double('contents', pluck: [1, 4, 5]))
        @service.stub(:recent_for_type).with(@type2).and_return(double('contents', pluck: [12, 37]))
        @service.stub(:recent_for_type).with(@type3).and_return(double('contents', pluck: []))
      end
      context 'given it finds and destroys the user' do
        before do
          CB::Core::User.stub(:find).with(37).and_return(@user)
          @user.should_receive(:destroy).and_return(true)
        end
        it 'enqueues the delete_contents_images jobs for all contents of each content types he uses' do
          JobRunner.should_receive(:run).with(DeleteContentsImages, @user.id, [1, 4, 5])
          JobRunner.should_receive(:run).with(DeleteContentsImages, @user.id, [12, 37])

          DeleteUser.do_perform(37)
        end
      end
      context 'given it finds but fails while destroying the content type' do
        before do
          CB::Core::User.stub(:find).with(37).and_return(@user)
          @user.should_receive(:destroy).and_return(false)
        end
        it 'does not enqueue any delete_contents_images job' do
          JobRunner.should_receive(:run).with(DeleteContentsImages, @user.id, anything()).never
          JobRunner.should_receive(:run).with(DeleteContentsImages, @user.id, anything()).never

          expect{DeleteUser.do_perform(37)}.to raise_error('Could not destroy user 37')
        end
      end
    end
  end
end