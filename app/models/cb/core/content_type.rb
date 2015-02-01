class CB::Core::ContentType < ActiveRecord::Base
  extend FriendlyId
  after_create :add_id_to_slug, :add_usage_for_owner

  has_many   :properties, -> { order :position } , class_name: 'CB::Core::ContentProperty', foreign_key: :father_type_id, dependent: :destroy
  has_many   :contents, class_name: 'CB::Core::Content', dependent: :destroy
  has_many   :sections, class_name: 'CB::Core::Section', dependent: :destroy

  belongs_to :owner, class_name: 'User'
  belongs_to :origin_type, class_name: 'CB::Core::ContentType'

  accepts_nested_attributes_for :properties, allow_destroy: true
  validates_presence_of :title

  friendly_id :title_for_slug, use: [:slugged, :scoped], scope: :owner, slug_column: :name

  def title_for_slug
    by_platform? ? title : "#{title}_#{id}"
  end

  def translated_title
    by_platform? ? I18n.t("content_type_name.#{name}") : title
  end

  def add_id_to_slug
    unless by_platform?
      slug = nil
      self.save!
    end
  end

  def should_generate_new_friendly_id?
    title_changed?
  end

  scope :owned_by,          -> (user) {where(owner_id: user.id)}
  scope :with_owner,        -> {includes(:owner)}
  scope :basic,             -> {where(composite: false)}
  scope :usable_by_default, -> {where(usable_by_default: true)}

  def add_usage_for_owner
    create_usage(owner_id) if owner_id
  end

  def add_usage_for_user user
    create_usage user.id
  end

  def owned_by? user
    owner_id == user.id
  end

  def properties_id_hash
    self.properties.pluck(:name, :id).to_h
  end

  alias_method :can_he_edit?, :owned_by?

private

  def create_usage user_id
    CB::Core::ContentTypeUsage.create!(user_id: user_id, content_type_id: self.id)
  end

end