class CB::Core::ContentTypeUsage < ActiveRecord::Base
  belongs_to :content_type, class_name: 'CB::Core::ContentType'
  belongs_to :user,         class_name: 'CB::Core::User'
end