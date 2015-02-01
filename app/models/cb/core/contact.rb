class CB::Core::Contact < ActiveRecord::Base

  has_many :channel_subscriptions, class_name: 'CB::Core::ChannelSubscription', foreign_key: :contact_id, dependent: :destroy

  validates_presence_of   :email
  validates_uniqueness_of :email, scope: :owner_id
  validates_format_of     :email, with:  Devise.email_regexp

end
