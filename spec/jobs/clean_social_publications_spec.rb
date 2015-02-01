require 'spec_helper'

describe CleanSocialPublications do
  describe "do_perform" do
    it 'loops throug the given array, and for each, runs the CleanSocialPublication job' do
      JobRunner.should_receive(:run).with(CleanSocialPublication, 12, 'azerty').once
      JobRunner.should_receive(:run).with(CleanSocialPublication, 42, 'qwerty').once
      JobRunner.should_receive(:run).with(CleanSocialPublication, 37, 'bepo'  ).once
      
      CleanSocialPublications.do_perform [ [12, 'azerty'], [42, 'qwerty'], [37, 'bepo'] ]
    end
  end
end