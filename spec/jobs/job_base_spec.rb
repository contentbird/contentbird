require 'spec_helper'

class DummyJob < JobBase
  def self.do_perform param1, param2
    "I ran with locale #{I18n.locale} with param1 #{param1} and param2 #{param2}"
  end
end

describe JobBase do
  describe "perform" do
    it 'call do_perform method in the given locale' do
      DummyJob.perform('piratelocale', 37, false).should eq "I ran with locale piratelocale with param1 37 and param2 false"
    end
  end
end