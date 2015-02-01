class CB::Core::Section < ActiveRecord::Base
  extend FriendlyId

  belongs_to :channel, class_name: 'CB::Core::Channel'
  belongs_to :content_type, class_name: 'CB::Core::ContentType'

  validates_presence_of :title, :position, :mode, :content_type_id

  friendly_id :title, use: [:slugged, :scoped], scope: :channel

  def should_generate_new_friendly_id?
    title_changed?
  end
end