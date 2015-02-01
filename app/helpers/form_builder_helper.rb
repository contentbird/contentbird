module FormBuilderHelper
  def self.included(base)
    ActionView::Base.default_form_builder = CBFormBuilder
  end

  class CBFormBuilder < ActionView::Helpers::FormBuilder

    def submit caption=nil, options={}
      options[:class] = "butn action #{options[:class]}"
      @template.content_tag(:button, (caption || submit_default_value), options)
    end

  end
  
end