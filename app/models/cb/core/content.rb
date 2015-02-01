class CB::Core::Content < ActiveRecord::Base
  extend FriendlyId

  before_save :refresh_exportable_properties_if_properties_changed
  after_save  :propagate_slug_change_to_website_publications

  belongs_to :content_type, counter_cache: true
  belongs_to :owner, class_name: 'CB::Core::User'

  has_many :publications, dependent: :destroy
  has_many :published_channels, through: :publications, source: :channel

  serialize :properties, Hash
  serialize :exportable_properties, Hash

  validates_presence_of :title, :content_type_id

  friendly_id :title, use: [:slugged, :scoped], scope: :owner

  paginates_per 10

  scope :owned_by, -> (user) {where(owner_id: model_id(user))}
  scope :of_type, -> (type) {where(content_type_id: model_id(type))}
  scope :recent, -> { order('updated_at DESC') }
  scope :published_on_channel, -> (channel) {joins(:publications).where('publications.channel_id = ?', channel.id)}
  scope :search_on_title, -> (search_string) { where('title @@ ?', search_string) }

  def publications_by_channel
    h = {}
    publications.each {|pub| h[pub.channel_id.to_s] = pub}
    h
  end

  def active_social_publications
    publications.to_a.select{ |publication| publication.provider_ref.present? }
  end

  def refresh_exportable_properties_if_properties_changed
    set_exportable_properties if properties_changed?
  end

  def set_exportable_properties pre_loaded_properties=nil
    type_properties = pre_loaded_properties || content_type.properties.includes(:content_type)
    result = {}
    first_media_prop, first_url_prop = nil, nil

    type_properties.each do |property|
      first_media_prop   = property if first_media_prop.nil? && filled_media_property?(property)
      first_url_prop     = property if first_media_prop.nil? && first_url_prop.nil? && filled_url_property?(property)
      result[property.name] = { 'title' => property.title,
                                'value' => (property.export_value(self.properties[property.id.to_s]) if self.properties.present?),
                                'type'  => property.content_type.name,
                                'i18n'  => self.content_type.by_platform }
    end

    set_first_image_fields(first_media_prop, first_url_prop, result)

    self.exportable_properties = result
  end

  def exportable_properties
    pties = self.read_attribute(:exportable_properties)
    pties.each do |name, property|
      property['title'] = I18n.t("content_type_properties_name.#{self.content_type.name}.#{name}") if property['i18n']
    end
    pties
  end

  def first_image_property
    exportable_properties[first_image_property_key] if first_image_property_key
  end

  def first_textual_property_key
    return @first_textual_property_key if @first_textual_property_key
    @first_textual_property_key = first_property_key_by_types(['text', 'memo', 'phone', 'email'])
  end

  def first_textual_property
    exportable_properties[first_textual_property_key] if first_textual_property_key
  end

  def should_generate_new_friendly_id?
    @slug_changing = title_changed?
  end

  def propagate_slug_change_to_website_publications
    if @slug_changing
      self.publications.joins(:channel).where('channels.type = ?', 'CB::Core::WebsiteChannel').update_all(url_alias: self.slug)
    end
  end

private

  def first_property_key_by_types types
    property_key = nil
    exportable_properties.each do |property_name, property|
      if types.include? property['type']
        property_key = property_name
        break
      end
    end
    property_key
  end

  def filled_media_property? property
    ['image', 'image_gallery'].include?(property.content_type.name) && self.properties.try(:[], property.id.to_s).present?
  end

  def filled_url_property? property
    property.content_type.name == 'url'  && self.properties.try(:[], property.id.to_s).present?
  end

  def set_first_image_fields media_prop, url_prop, props_hash
    if media_prop
      self.first_image_property_key  = media_prop.name
      first_image_value              = props_hash[media_prop.name]
      self.first_image_property_url  = CB::Core::Media.thumbnail_url(first_image_value['value'].is_a?(Array) ? first_image_value['value'].first.try(:[],'url') : first_image_value['value'])
    elsif url_prop
      self.first_image_property_url  = CB::Core::Media.image_for_url(props_hash[url_prop.name]['value'])
      self.first_image_property_key  = self.first_image_property_url.present? ? url_prop.name : nil
    else
      self.first_image_property_key = nil
      self.first_image_property_url = nil
    end
  end

end