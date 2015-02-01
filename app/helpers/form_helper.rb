module FormHelper
  def link_to_add_fields name, f, association, link_data_options
    new_object = f.object.send(association).klass.new
    id         = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render(association.to_s.singularize + "_fields", f: builder)
    end
    link_to(name, '#', class: "butn _addFields", data: {icon: raw("&#xe00e;"), id: id, fields: fields.gsub("\n", "")}.merge(link_data_options))
  end

  def flash_display
    response = ""
    flash.each do |name, msg|
      response = response + content_tag(:div, msg, class: name)
    end
    flash.discard
    response
  end
end