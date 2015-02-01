require 'spec_helper'

describe PublicationHelper do
  describe '#unpublish_countdown' do
    it 'returns next hour text if given date is within next hour' do
      unpublish_countdown(50.minutes.from_now).should eq '1 hour top'
    end
    it 'returns the expire date using time ago formats if given date is farer than 1 hour from now' do
      unpublish_countdown(2.hours.from_now).should eq 'translation missing: test.datetime.distance_in_words.about_x_hours'
    end
  end
  describe '#time_button' do
    context 'given a publication expiring in 5 hours' do
      before do
        freeze_time
        @publication_5h      = OpenStruct.new(expire_at: 5.hours.from_now,   to_param: '12')
        @publication_24h     = OpenStruct.new(expire_at: 24.hours.from_now,  to_param: '12')
        @publication_4_days  = OpenStruct.new(expire_at: 4.days.from_now,    to_param: '12')
        @publication_7_days  = OpenStruct.new(expire_at: 7.days.from_now,    to_param: '12')
        @publication_3_weeks = OpenStruct.new(expire_at: 3.weeks.from_now,   to_param: '12')
      end

      it 'displays an active link with data attribute "never" it expirartion date fits within timeframe, and inactive link with data attribute timeframe otherwise' do
        time_button(@publication_5h,  :day).should        eq link_to('1 day',   update_expiration_publication_path(@publication_5h), class: "butn _changeTime active",      data: {expire_in: 'never'})
        time_button(@publication_5h,  :week).should       eq link_to('1 week',  update_expiration_publication_path(@publication_5h), class: "butn _changeTime",             data: {expire_in: 'week'})
        time_button(@publication_5h,  :month).should      eq link_to('1 month', update_expiration_publication_path(@publication_5h), class: "butn _changeTime",             data: {expire_in: 'month'})

        time_button(@publication_24h, :day).should        eq link_to('1 day',   update_expiration_publication_path(@publication_24h), class: "butn _changeTime active",     data: {expire_in: 'never'})
        time_button(@publication_24h,  :week).should      eq link_to('1 week',  update_expiration_publication_path(@publication_24h), class: "butn _changeTime",            data: {expire_in: 'week'})
        time_button(@publication_24h,  :month).should     eq link_to('1 month', update_expiration_publication_path(@publication_24h), class: "butn _changeTime",            data: {expire_in: 'month'})

        time_button(@publication_4_days, :day).should     eq link_to('1 day',   update_expiration_publication_path(@publication_4_days), class: "butn _changeTime",         data: {expire_in: 'day'})
        time_button(@publication_4_days, :week).should    eq link_to('1 week',  update_expiration_publication_path(@publication_4_days), class: "butn _changeTime active",  data: {expire_in: 'never'})
        time_button(@publication_4_days, :month).should   eq link_to('1 month', update_expiration_publication_path(@publication_4_days), class: "butn _changeTime",         data: {expire_in: 'month'})

        time_button(@publication_7_days, :day).should     eq link_to('1 day',   update_expiration_publication_path(@publication_7_days), class: "butn _changeTime",         data: {expire_in: 'day'})
        time_button(@publication_7_days, :week).should    eq link_to('1 week',  update_expiration_publication_path(@publication_7_days), class: "butn _changeTime active",  data: {expire_in: 'never'})
        time_button(@publication_7_days, :month).should   eq link_to('1 month', update_expiration_publication_path(@publication_7_days), class: "butn _changeTime",         data: {expire_in: 'month'})

        time_button(@publication_3_weeks, :day).should    eq link_to('1 day',   update_expiration_publication_path(@publication_3_weeks), class: "butn _changeTime",        data: {expire_in: 'day'})
        time_button(@publication_3_weeks, :week).should   eq link_to('1 week',  update_expiration_publication_path(@publication_3_weeks), class: "butn _changeTime",        data: {expire_in: 'week'})
        time_button(@publication_3_weeks, :month).should  eq link_to('1 month', update_expiration_publication_path(@publication_3_weeks), class: "butn _changeTime active", data: {expire_in: 'never'})
      end
    end
  end

end