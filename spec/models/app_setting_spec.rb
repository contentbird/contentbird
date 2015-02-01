require 'spec_helper'

describe AppSetting do
  describe 'attributes persistance' do
    it 'mass assigns key and value' do
      app_setting = AppSetting.create(key: 'max_threshold', value: '100')
      app_setting.reload
      app_setting.key.should    eq 'max_threshold'
      app_setting.value.should  eq '100'
    end
  end

  describe 'short and convenient accessors returning hashes or primitives' do
    before do
      AppSetting.create(key: 'threshold_min', value: '100')
      AppSetting.create(key: 'threshold_max', value: '150')
      AppSetting.create(key: 'some_var', value: '1')
    end

    it '[] returns only the value or nil if key not found' do
      AppSetting['threshold_min'].should  eq '100'
      AppSetting['not_found'].should      be_nil
    end

    it '[]= set the given value and returns the setted value if key exists' do
      AppSetting['threshold_min']='10'
      AppSetting.find_by_key('threshold_min').value.should eq '10'
    end

    it '[]= returns nil if the key does not exist' do
      expect{AppSetting['not_found']='20'}.to change{AppSetting['not_found']}.from(nil).to('20')
    end

    it '#like returns a hash of matching keys-values' do
      AppSetting.like('threshold').should eq({'threshold_min' => '100', 'threshold_max' => '150'})
    end

    it '#for_keys returns a hash of matching keys-values' do
      AppSetting.for_keys('threshold_min', 'some_var').should eq({'threshold_min' => '100', 'some_var' => '1'})
    end
  end
end