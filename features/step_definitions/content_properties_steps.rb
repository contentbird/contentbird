module ContentPropertiesSteps
  def fill_title_property property, value
    find('#edit_content').fill_in 'content_title', with: value
  end

  def fill_text_property property, value
    find('#edit_content').fill_in property.capitalize, with: value
  end

  def fill_image_property property, value
    find("#edit_content ._add-#{property} a._addImage").click()
    within '#modal' do
      attach_file('file', Rails.root.to_s + "/spec/fixtures/files/" + value)
    end
  end

  def check_title_property property, value
    if current_path =~ /edit/
      find('.contents #content_title').value.should eq value
    else #show
      find('.content #content_title').text.should eq value
    end
  end

  def check_text_property property, value
    if current_path =~ /edit/
      find('.contents').find_field(property.capitalize).value.should eq value
    else #show
      find(".content .cb-prop-#{property}").should have_text("#{property}: #{value}")
    end
  end

  def check_image_property property, value
    if current_path =~ /edit/
      find(".contents ._add-#{property} ._imagePreview")['src'].should be_present  #impossible to compate original image name with uploaded one
    else #show
      find(".content .cb-prop-#{property} img")['src'].should          be_present  #impossible to compate original image name with uploaded one
    end
  end

  alias_method :check_url_property, :check_text_property

end