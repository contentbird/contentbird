class CB::Core::ContentProperty < ActiveRecord::Base
  extend FriendlyId

  belongs_to :content_type
  belongs_to :father_type, class_name: 'CB::Core::ContentType'

  validates_presence_of     :title, :position, :content_type_id
  validates_numericality_of :position

  friendly_id :title, use: [:slugged, :scoped], scope: :father_type, slug_column: :name

  def translated_title eager_loaded_content_type=nil
    type = eager_loaded_content_type || self.father_type
    type.by_platform? ? I18n.t("content_type_properties_name.#{type.name}.#{self.name}") : title
  end

  def media?
    %w{image image_gallery}.include? content_type.name
  end

  def export_value value
    if media?
      if value.present?
        if value.is_a?(Array)
          value.map{|element| element.merge({'url' => CB::Core::Media.media_url(content_type.name.to_sym, element['url'])})}
        else
          CB::Core::Media.media_url(content_type.name.to_sym, value)
        end
      end
    else
      value
    end
  end

  def should_generate_new_friendly_id?
    title_changed?
  end
end