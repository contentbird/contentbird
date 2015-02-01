class AppSetting < ActiveRecord::Base
  def self.[] key
    AppSetting.find_by_key(key.to_s).try(:value)
  end

  def self.[]= key, value
    aps = AppSetting.find_or_create_by(key: key.to_s)
    aps.update_attribute(:value, value)
  end

  def self.like key
    AppSetting.where("key like ?", key.split('*').first+'%').each_with_object({}) {|s,h| h[s.key]=s.value}
  end

  def self.for_keys *keys_array
    AppSetting.where(key: keys_array).each_with_object({}) {|s,h| h[s.key]=s.value}
  end
end