require 'securerandom'

class CB::Core::Publication < ActiveRecord::Base

  before_create {self.published_at = Time.now}

  belongs_to :channel, class_name: 'CB::Core::Channel'
  belongs_to :content, class_name: 'CB::Core::Content', counter_cache: true
  has_one    :user,    through: :content, source: :owner

  validates_uniqueness_of :channel_id, scope: :content_id

  default_scope { where(deleted_at: nil) }
  scope :recent, -> { order('published_at DESC') }
  scope :with_content, -> { includes(:content) }
  scope :with_content_and_type, -> { includes(content: :content_type) }
  scope :from_channel, -> (channel) { where(channel_id: channel.id) }
  scope :with_url_alias, -> (url_alias) { where(url_alias: url_alias) }
  scope :of_content_type, -> (content_type) { joins(:content).where('contents.content_type_id = ?', model_id(content_type)) }
  scope :owned_by, -> (user) { joins(:content).where('contents.owner_id = ?', model_id(user)) }
  scope :expired_to_delete, -> { where('expire_at <= ?',Time.now).where('failed_unpublish_count < 3').includes(:user) }

  def permalink chan = nil
    chan ||= channel
    return '#' if chan.api?
    "http://#{chan.web_url}/#{chan.social? ? 'p' : 'permalink'}/#{url_alias}"
  end

  def self.first_deleted_for_channel_and_content channel, content
    unscoped { where.not(deleted_at: nil).from_channel(channel).where(content_id: content.id) }.first
  end

  def self.generate_url_alias
    url_alias = nil
    begin
      url_alias = SecureRandom.urlsafe_base64(8)
    end while self.exists?(url_alias: url_alias)
    url_alias
  end

  def soft_delete
    updated = nil
    self.transaction do
      updated = update_attributes(deleted_at: Time.now, expire_at: nil, failed_unpublish_count: 0, last_failed_unpublish_at: nil, last_failed_unpublish_message: nil)
      CB::Core::Content.reset_counters(self.content_id, :publications) if updated
    end
    self.deleted_at = nil unless updated
    updated
  end

  def undelete
    previous_deteled_at = deleted_at
    updated = nil
    self.transaction do
      updated = update_attributes(deleted_at: nil)
      CB::Core::Content.reset_counters(self.content_id, :publications) if updated
    end
    self.deleted_at = previous_deteled_at unless updated
    updated
  end

  def deleted?
    deleted_at.present?
  end

  def reset_provider_ref ref=nil
    previous_ref = provider_ref
    reseted = update_attributes(provider_ref: ref)
    self.provider_ref = previous_ref unless reseted
    reseted
  end
end