module ContentTypeSteps
  def db_create_content_type params
    CB::Core::ContentType.create!(params.merge!(title: params[:name], composite: false))
  end

  def db_find_content_type name
    CB::Core::ContentType.find_by_title(name)
  end

  def db_create_content_property params
    CB::Core::ContentProperty.create!(params.merge!(title: params[:name]))
  end

  def create_content_type content_name, content_properties_array
    visit content_types_path
    click_on 'New format'
    within '.contents-types' do
      fill_in 'content_type_title', with: content_name
      content_properties_array.each_with_index do |content_property, index|
        click_on 'Add property'
        if index == 0
          fill_in 'title', with: content_property[:name]
          select content_property[:content_type], from: 'content_type_id'
        else
          all(:xpath, "//input[@id[starts-with(.,'content_type_properties_attributes') and contains(.,'title')]]").at(1).set(content_property[:name])
          all(:xpath, "//select[@id[starts-with(.,'content_type_properties_attributes') and contains(.,'content_type_id')]]").at(1).select(content_property[:content_type])
        end
      end
      click_on 'Create content_type'
    end
  end

  def edit_content_type content_type_name
    visit content_types_path
    content_type = db_find_content_type(content_type_name)

    find('#ct_list').click_on("ct_edit_#{content_type.to_param}")
  end

  def update_content_type content_type_name, content_type_changes
    within '.contents-types' do
      fill_in 'content_type_title', with: content_type_name
      content_type_changes.each do |content_change|
        if content_change[:action] == 'add'
          click_on 'Add property'
          all(:xpath, "//input[@id[starts-with(.,'content_type_properties_attributes') and contains(.,'title')]]").last.set(content_change[:new_name])
          all(:xpath, "//select[@id[starts-with(.,'content_type_properties_attributes') and contains(.,'content_type_id')]]").last.select(content_change[:new_content_type])
        else
          index = find("input[value='#{content_change[:name]}']")[:id][35]
          if content_change[:action] == 'update'
            fill_in "content_type_properties_attributes_#{index}_title", with: content_change[:new_name]
            select content_change[:new_content_type], from: "content_type_properties_attributes_#{index}_content_type_id"
          elsif content_change[:action] == 'delete'
            find("#ct-del-#{index}").trigger('click')
          end
        end
      end
      click_on 'Update content_type'
    end
    @content_type_changes = content_type_changes
  end

  def delete_content_type content_type_name
    @deleted_content_type = db_find_content_type(content_type_name)

    edit_content_type content_type_name
    click_on 'Delete'
  end

  def check_content_type_created content_type_name
    current_path.should eq content_types_path
    page.body.should have_content 'Your format was saved'

    content_type = db_find_content_type(content_type_name)
    check_content_type_listed   content_type
  end

  def check_content_type_updated content_type_name
    current_path.should eq content_types_path
    page.body.should have_content 'Your format was saved'

    edit_content_type           content_type_name
    check_content_type_detailed content_type_name, true
  end

  def check_content_type_deleted content_type_name=nil
    content_type = content_type_name.nil? ? @deleted_content_type : db_find_content_type(content_type_name)
    current_path.should eq content_types_path
    page.body.should have_content 'Your format was deleted'

    check_content_type_not_listed content_type
  end

  def check_content_type_listed content_type
    within("#ct_list #ct_#{content_type.to_param}") do
      page.should have_text(content_type.title)
    end
  end

  def check_content_type_not_listed content_type
    page.should_not have_css("#ct_list #ct_#{content_type.to_param}")
  end

  def check_content_type_detailed content_type_name, like_described=false
    content_type = db_find_content_type(content_type_name)

    current_path.should eq edit_content_type_path(content_type.id)
    if like_described
      @content_type_changes.each do |content_change|
        if content_change[:action] == 'add' || content_change[:action] == 'update'
          index = find("input[value='#{content_change[:new_name]}']")[:id][35]
          find_field("content_type_properties_attributes_#{index}_content_type_id").find('option[selected]').text.split('_').first.should eq content_change[:new_content_type]
        elsif content_change[:action] == 'delete'
          page.body.should_not have_css("input[value='#{content_change[:name]}']")
        end
      end
    else
      find('#content_type_title').value.should eq content_type.title
      content_type.properties.each_with_index do |property, index|
        find("#content_type_properties_attributes_#{index}_title").value.should eq property.title
        find_field("content_type_properties_attributes_#{index}_content_type_id").find('option[selected]').text.should eq property.content_type.name
      end
    end
  end

  def check_content_types_suggested_for_creation content_types
    find('#createContent').should be_visible
    within('#createContent') do
      expect(page).to have_selector('ul li', count: content_types.count)
      content_types.each do |content_type|
        find_link(content_type.title)[:href].should eq new_content_path(content_type_id: content_type.id)
      end
    end
  end

  def set_default_content_types_usages_to_all_users
    CB::Core::User.all.each do |user|
      CB::Build::Account.new(user).set_default_content_types_usages
    end
  end

  def add_properties_to_content_type content_properties, content_type
    content_properties.hashes.each_with_index do |content_property_params, index|
      not_assignable_attributes = %w(content_type)
      property_content_type     = db_find_content_type(content_property_params[:content_type])
      property                  = db_create_content_property(content_property_params.reject!{|k,v| not_assignable_attributes.include?(k)}
                                                                                    .merge!(content_type_id: property_content_type.id, position: index))
      content_type.properties << property
    end
    content_type.save!
  end

  def create_owner email
    email == 'the_platform' ? OpenStruct.new(id: 3) : db_find_user(email)
  end

end

World(ContentTypeSteps)

Given(/^"(.*?)" are basic content types$/) do |content_type_list|
  content_type_list.split(', ').each do |content_type_name|
    db_create_content_type(name: content_type_name, by_platform: true)
  end
end

Given(/^"(.*?)" content types? (is|are) usable by default$/) do |content_type_list, is_or_are|
  content_type_list.split(', ').each do |content_type_name|
    db_create_content_type({name: content_type_name, usable_by_default: true})
  end
end

Given(/^the following user content types$/) do |content_types|
  content_types.hashes.each do |content_type_params|
    owner = db_find_user(content_type_params[:owner])

    not_assignable_attributes = %w(owner)

    db_create_content_type(content_type_params.reject!{|k,v| not_assignable_attributes.include?(k)}
                                           .merge!(owner_id: owner.id))
  end
end

Given(/^"(.*?)" is a( usable)? content type owned by "(.*?)" with the following content_properties$/) do |content_type_name, usable, owner_email, content_properties|
  owner        = create_owner(owner_email)
  content_type = db_create_content_type(name:              content_type_name,
                                        owner_id:          owner.id,
                                        by_platform:       owner_email == 'the_platform',
                                        usable_by_default: usable == ' usable')

  add_properties_to_content_type(content_properties, content_type)
  set_default_content_types_usages_to_all_users if usable == ' usable'
end

Then(/^content_type "(.*?)" is listed$/) do |content_type_name|
  content_type = db_find_content_type(content_type_name)
  check_content_type_listed(content_type)
end

Then(/^content_type "(.*?)" is not listed$/) do |content_type_name|
  content_type = db_find_content_type(content_type_name)
  check_content_type_not_listed content_type
end

When(/^he edits "(.*?)" content_type$/) do |content_type_name|
  edit_content_type content_type_name
end

When(/^he creates a new content_type "(.*?)" with the following content_properties$/) do |content_type_name, content_properties|
  create_content_type(content_type_name, content_properties.hashes)
end

Then(/^the content_type "(.*?)" is created$/) do |content_type_name|
  check_content_type_created content_type_name
end

Then(/^"(.*?)" content_type is detailed$/) do |content_type_name|
  check_content_type_detailed content_type_name
end

When(/^he updates the content_type "(.*?)" like this$/) do |content_type_name, content_type_changes|
  update_content_type(content_type_name, content_type_changes.hashes)
end

Then(/^content_type "(.*?)" is updated like described$/) do |content_type_name|
  check_content_type_updated content_type_name
end

When(/^he deletes "(.*?)" content_type$/) do |content_type_name|
  delete_content_type content_type_name
end

Then(/^content_type(?: "(.*?)")? is deleted$/) do |content_type_name|
  check_content_type_deleted content_type_name
end

Then(/^a new content of type "(.*?)" is suggested for creation$/) do |content_type_list|
  content_types = []
  content_type_list.split(', ').each do |content_type_name|
    content_types << db_find_content_type(content_type_name)
  end
  check_content_types_suggested_for_creation(content_types)
end