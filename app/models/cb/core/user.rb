class CB::Core::User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :channels,         class_name: 'CB::Core::Channel',        foreign_key: :owner_id, dependent: :destroy
  has_many :website_channels, -> {where type: 'CB::Core::WebsiteChannel'}, class_name: 'CB::Core::Channel', foreign_key: :owner_id
  has_many :social_channels,  -> {where type: 'CB::Core::SocialChannel'},  class_name: 'CB::Core::Channel', foreign_key: :owner_id

  has_many :contents,       class_name: 'CB::Core::Content',      foreign_key: :owner_id

  has_many :own_content_types,    class_name: 'CB::Core::ContentType',      foreign_key: :owner_id, dependent: :destroy
  has_many :content_type_usages,  class_name: 'CB::Core::ContentTypeUsage', dependent: :destroy
  has_many :content_types,        class_name: 'CB::Core::ContentType',      through: :content_type_usages

  validates_uniqueness_of :nest_name
  validates_presence_of   :email, :nest_name

  attr_accessor :token

  def number_of_channels_by_provider
    social_channels.group(:provider).count
  end

  def first_website_channel
    website_channels.first
  end

  def update_with_password(params, *options)
    params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = update_attributes(params, *options)

    clean_up_passwords
    result
  end

  def advanced?
    admin || platform_user || advanced_user
  end

  def announcement_clicked! code
    self.update_attribute(:last_announcement_clicked, code)
  end

  def announcement_clicked? code
    last_announcement_clicked == code
  end

end