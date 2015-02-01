class CB::Core::ChannelSubscription < ActiveRecord::Base
  belongs_to :channel, class_name: 'CB::Core::MessagingChannel', foreign_key: :channel_id
  belongs_to :contact, class_name: 'CB::Core::Contact',          foreign_key: :contact_id

  validates_uniqueness_of :contact_id, scope: :channel_id

  scope :for_channel_and_email, -> (channel, email) { joins(:contact).where(channel_id: model_id(channel)).where('contacts.email = ?', email) }

  def self.find_for_channel_and_email search_channel, email
  	CB::Core::ChannelSubscription.for_channel_and_email(search_channel, email).readonly(false).first
  end
end
