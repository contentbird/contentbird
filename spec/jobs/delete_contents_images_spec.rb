require 'spec_helper'

describe DeleteContentsImages do
  describe "do_perform" do
    it 'uses storage to delete all content for this user and contents' do
      Storage.stub(:new).with(:content_image).and_return(storage = double('image storage'))

      storage.should_receive(:delete_all_starting_with_path).with('12/37/').once
      storage.should_receive(:delete_all_starting_with_path).with('12/42/').once
      storage.should_receive(:delete_all_starting_with_path).with('12/256/').once

      DeleteContentsImages.do_perform(12, [37, 42, 256])
    end
  end
end