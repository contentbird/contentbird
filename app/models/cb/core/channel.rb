class CB::Core::Channel < ActiveRecord::Base
  before_create :generate_access_token

  belongs_to :owner, class_name: 'User'
  has_many   :sections, -> { order 'position' }, dependent: :destroy
  has_many   :publications, dependent: :destroy
  has_many   :published_contents, through: :publications

  accepts_nested_attributes_for :sections, allow_destroy: true

  validates_presence_of    :name
  validates_presence_of    :url_prefix, unless: lambda { |chan| chan.is_a? CB::Core::APIChannel }
  validates_uniqueness_of  :url_prefix, unless: lambda { |chan| chan.is_a? CB::Core::APIChannel }
  validates_exclusion_of   :url_prefix, in: :excluded_url_prefixes

  scope :opened,           -> {where(closed_at: nil)}
  scope :for_prefix,       -> (prefix) {where(url_prefix: prefix)}
  scope :for_credentials,  -> (key,secret) {where(id: key, access_token: secret)}
  scope :only_basic_info,  -> {select(:id, :access_token, :type)}
  scope :owned_by,         -> (owner) { where(owner_id: model_id(owner)) }

  mount_uploader :css, ChannelCssUploader

  def self.inherited(child)
    child.instance_eval do
      def model_name
        alias :original_model_name :model_name
        CB::Core::Channel.model_name
      end
    end
    super
  end

  def self.generate_url_prefix
    url_pref = nil
    begin
      url_pref = SecureRandom.urlsafe_base64(8).downcase
    end while self.exists?(url_prefix: url_pref)
    url_pref
  end

  def self.types
    %w(website social api)
  end

  def excluded_url_prefixes
    EXCLUDED_URL_PREFIXES || ['www', 'api', 'payment', 'admin']
  end

  def closed?
    self.closed_at
  end

  def generate_access_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end

  def home_section
    sections.first
  end

  def generate_url_alias
  end

  def social?
    false
  end

  def api?
    false
  end

  def messaging?
    false
  end

  def cover_url
    STORAGE[:"channel_media"][:url] + "/#{cover}" if cover.present?
  end

  def web_url
    "#{url_prefix}.#{WEBSITE_DOMAIN}"
  end

  def last_publication_at
    @last_publication_at ||= publications.recent.first.try(:published_at)
  end

  def save_with_new_url_prefix
    url_prefix_root = self.url_prefix
    cpt = 0
    while !self.save && self.errors.size == 1 && self.errors.first == [:url_prefix, I18n.t('activerecord.errors.models.cb/core/channel.attributes.url_prefix.taken')] do
      cpt = cpt + 1
      self.url_prefix = "#{url_prefix_root}-#{cpt}"
    end
  end

  def create_display_section_for_type_if_none content_type
    return false if sections.exists?(mode: 'display', content_type_id: content_type.id)
    sections.create!(mode: 'display', content_type_id: content_type.id, title: content_type.translated_title, position: sections.count)
    true
  end

end

class CB::Core::WebsiteChannel < CB::Core::Channel
  def pretty_type
    'Website'
  end

  def simple_type
    'website'
  end
end

class CB::Core::APIChannel < CB::Core::Channel
  def pretty_type
    'API'
  end

  def simple_type
    'api'
  end

  def api?
    true
  end
end

class CB::Core::SocialChannel < CB::Core::Channel
  validates_presence_of     :provider
  validates                 :provider, inclusion: { in: -> (record) {record.providers} }

  def providers
    %w(developer twitter facebook googleplus linkedin)
  end

  def provider_class
    "CB::Publish::#{provider.capitalize}".constantize
  end

  def pretty_type
    "Social - #{pretty_provider}"
  end

  def pretty_provider
    provider.capitalize
  end

  def simple_type
    "social"
  end

  def social?
    true
  end

  def create_display_section_for_type_if_none content_type
    raise NotImplementedError, 'Social channels do not use sections'
  end
end

class CB::Core::MessagingChannel < CB::Core::Channel
  before_validation         :set_url_prefix

  has_many :subscriptions, class_name: 'CB::Core::ChannelSubscription', foreign_key: :channel_id, dependent: :destroy
  has_many :contacts, through: :subscriptions, class_name: 'CB::Core::Contact', source: :contact

  accepts_nested_attributes_for :subscriptions, allow_destroy: true

  validates_presence_of     :provider
  validates                 :provider, inclusion: { in: -> (record) {record.providers} }

  def providers
    %w(email)
  end

  def pretty_provider
    provider.capitalize
  end

  def provider_class
    "CB::Publish::#{provider.capitalize}".constantize
  end

  def pretty_type
    "Messaging - #{pretty_provider}"
  end

  def simple_type
    "messaging"
  end

  def messaging?
    true
  end

private
  def set_url_prefix
    self.url_prefix = "ml-#{self.class.generate_url_prefix}" unless self.url_prefix.present?
  end

end