module ContentSteps
  include ContentPropertiesSteps

  def db_find_content name
    CB::Core::Content.find_by_title(name)
  end

  def db_create_content user, content_type, params
    user = CB::Core::User.last if user.nil?
    properties_params = {title: params[:title]}.merge!({properties: params.reject!{|k,v| k == 'title'}})
    res, content = CB::Manage::Content.new(user).create(content_type, properties_params)
    raise "db_create_content failed for #{content_type.title} with title #{params[:title]} : #{content.errors.messages}" unless res
    content
  end

  def create_content content_type_name, content_properties
    visit contents_path
    click_on "Create"
    click_on content_type_name
    update_content content_properties, db_find_content_type(content_type_name)
  end

  def edit_content content_name
    visit contents_path
    content = db_find_content(content_name)

    find('#content_list').click_on("content_edit_#{content.id}")
  end

  def update_content content_changes, content_type
    ph = properties_hash_for_content_type(content_type)
    content_changes.each do |k, v|
      self.send "fill_#{ph[k]}_property", k, v
    end
    click_on 'Update content'
    @accordingly = content_changes
  end

  def delete_content content_name
    @deleted_content = db_find_content(content_name)

    edit_content content_name
    click_on 'Delete'
  end

  def check_contents_count count
    expect(page).to have_selector('article.content', count: count)
  end

  def check_content_listed content
    within(".contents #content_#{content.id}") do
      page.should have_text(content.title)
    end
  end

  def check_content_not_listed content
    page.should_not have_css(".contents #content_#{content.id}")
  end

  def check_content_created content_name
    content = db_find_content(content_name)
    current_path.should eq content_path(content.id)

    page.body.should have_content "Your #{content.content_type.title} was saved !"

    check_content_detailed_accordingly content_name
  end

  alias_method :check_content_updated, :check_content_created

  def check_content_deleted content_name=nil
    content = content_name.nil? ? @deleted_content : db_find_content(content_name)
    current_path.should eq contents_path
    page.body.should have_content "Your #{content.content_type.title} #{content.title} was deleted"

    check_content_not_listed content
  end

  def check_content_detailed_accordingly content_name
    raise_error 'No content properties remembered. Please set @accordingly to memorize properties between steps' if @accordingly.nil?

    check_content_properties(content_name, @accordingly)
  end

  def check_content_detailed content_name, details
    check_content_properties(content_name, details)
  end

  def check_content_properties content_name, properties_hash
    content = db_find_content(content_name)
    content_properties = properties_hash_for_content content
    properties_hash.each do |property_name, property_value|
      self.send "check_#{content_properties[property_name]['type']}_property", property_name, property_value
    end
  end

  def filter_content_type content_type_name
    within(".actions") do
      select(content_type_name, from: 'content_type_id')
    end
  end

  def search_content_type search_string
    within(".actions") do
      fill_in 'search', with: search_string
      # TODO : Key down does not work with Poltergeist : submitting form manually to run search
      page.execute_script %Q{$('form').submit()}
      # Replace with line below once this is corrected https://github.com/jonleighton/poltergeist/issues/43
      # find('#search').native.send_key(:Return)
    end
  end

  def properties_hash_for_content content
    content.exportable_properties.merge('title' => {'type' => 'title'})
  end

  def properties_hash_for_content_type content_type
    #TODO: Might be usefull in content-type.rb
    properties      = content_type.properties.joins(:content_type).pluck('content_properties.title','content_types.name')
    properties.to_h.merge('title' => 'title')
  end

end

World(ContentSteps)

Given(/^he created the following "(.*?)" contents$/) do |content_type_name, contents|
  contents.hashes.each do |content_params|
    content_type = db_find_content_type(content_type_name)
    db_create_content(nil, content_type, content_params)
  end
end

When(/^he creates a new "(.*?)" content with the following properties$/) do |content_type_name, content_properties|
  create_content content_type_name, content_properties.hashes.first #because only one content, if many given : iterate
end

Then(/^contents? "(.*?)" (is|are) listed$/) do |contents, is_or_are|
  contents_array = contents.split(', ')
  check_contents_count contents_array.size
  contents_array.split(', ').each do |content_name|
    check_content_listed db_find_content(content_name)
  end
end

When(/^he filters "(.*?)" content types$/) do |content_type_name|
  filter_content_type(content_type_name)
end

When(/^he searches for "(.*?)" content type$/) do |search_string|
  search_content_type(search_string)
end

Then(/^the content "(.*?)" is created accordingly$/) do |content_name|
  check_content_created content_name
end

When(/^he edits "(.*?)" content$/) do |content_name|
  edit_content content_name
end

Then(/^"(.*?)" content is detailed accordingly$/) do |content_name|
  check_content_detailed_accordingly content_name
end

Then(/^"(.*?)" content is detailed like this$/) do |content_name, content_details|
  check_content_detailed content_name, content_details.hashes.first
end

When(/^he updates the content "(.*?)" like this$/) do |content_name, content_changes|
  update_content(content_changes.rows_hash.tap{|x| x.delete(x.keys.first)}, db_find_content(content_name).content_type) #Convert to hash like {col1: col2} and remove header
end

Then(/^content "(.*?)" is updated accordingly$/) do |content_name|
  check_content_detailed_accordingly content_name
end

When(/^he deletes "(.*?)" content$/) do |content_name|
  delete_content content_name
end

Then(/^content(?: "(.*?)")? is deleted$/) do |content_name|
  check_content_deleted content_name
end

When(/^he goes to see the details of content "(.*?)"$/) do |content_title|
  @current_content = db_find_content(content_title)
  visit content_path(@current_content.id)
end
