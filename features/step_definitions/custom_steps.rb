module CustomSteps
  def open_menu name
    click_link "#{name.downcase}MenuItem"
  end
end

World(CustomSteps)

Then /^show me the page$/ do
  save_and_open_page
end

When(/^he opens the "(.*?)" menu$/) do |menu_name|
  open_menu(menu_name)
end

When /^I wait for (\d+|\d+\.\d+) seconds?$/ do |n|
  sleep(n.to_f)
end