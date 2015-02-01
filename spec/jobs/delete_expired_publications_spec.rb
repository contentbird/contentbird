require 'spec_helper'

describe DeleteExpiredPublications do
  describe "do_perform" do
    it 'unpublishes all publications ready for automatic deletion' do
      CB::Core::Publication.stub(:expired_to_delete).and_return [ pub1 = OpenStruct.new(user: 'user1'),
                                                                  pub2 = OpenStruct.new(user: 'user2') ]

      CB::Manage::Publication.stub(:new).with('user1').and_return(publisher1 = double('publisher'))
      CB::Manage::Publication.stub(:new).with('user2').and_return(publisher2 = double('publisher'))

      publisher1.should_receive(:unpublish).with(pub1)
      publisher2.should_receive(:unpublish).with(pub2)

      DeleteExpiredPublications.do_perform
    end
  end
end