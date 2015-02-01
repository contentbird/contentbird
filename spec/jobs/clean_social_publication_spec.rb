require 'spec_helper'

describe CleanSocialPublication do
  describe "do_perform" do
    it 'gets the channel matching the given id, instanciates its provider class and unpublishes the given publication reference' do
      CB::Core::Channel.stub(:find).with(12).and_return(channel_double = double('twitter channel', provider_class: CB::Publish::Twitter))
      CB::Publish::Twitter.stub(:new).with(channel_double).and_return(publisher_double = double('twitter publisher'))

      publisher_double.should_receive(:unpublish_from_provider).with('azerty123')
      
      CleanSocialPublication.do_perform 12, 'azerty123'
    end
  end
end