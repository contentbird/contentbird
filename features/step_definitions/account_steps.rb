module AccountSteps
  def login(email, password)
    visit '/app/users/sign_in'
    fill_in 'user_email',     with: email
    fill_in 'user_password',  with: password
    click_button 'Log in'
  end

  def check_login_displays_message result
    if result == 'success'
      find('div.notice').should have_content('Signed in successfully.')
    elsif result == 'fail'
      find('div.alert').should have_content('Invalid email or password.')
    else
      @current_scenario.fail! raise("login message '#{result}' is not supported should be 'success' or 'fail'")
    end
  end

  def check_signup_suggested
    page.should have_selector(:link_or_button, 'signupBtn')
  end

  def app_accessible ok_or_not
    visit '/app/content_types'
    current_path.should eq(ok_or_not ? '/app/content_types' : '/app/users/sign_in')
  end

  def db_create_user email, advanced=false
    @user = CB::Core::User.create!(email: email, password: 'PassW0rd', nest_name: email.split('@').first, advanced_user: advanced)
  end

  def db_find_user email
    CB::Core::User.find_by_email(email)
  end

  def proceed_to_signup
    find('#signupBtn').trigger('click')
    sleep(1)
  end

  def fill_registration_form
    user = FactoryGirl.build :user
    fill_in 'user_nest_name',             with: user.nest_name
    fill_in 'user_email',                 with: user.email
    fill_in 'user_password',              with: user.password
    click_button 'Create my account'

    @user = db_find_user user.email
  end

  def check_default_website_with_current_user_nest_name
    find('#websiteUrl').text.should eq "#{@user.nest_name}.contentbird.me"
  end

  def add_twitter_account
    find('#addTwitterBtn').click
  end

  def check_twitter_is_done
    page.should have_selector('#addedTwitterImg')
  end

  def check_no_contents_displayed
    within(".contents") do
      page.should_not have_css(".content")
    end
  end

  def db_check_twitter_channel_created
    @user.social_channels.where(provider: 'twitter').count.should eq 1
  end

  def done_adding_social_channels
    click_on 'doneBtn'
  end
end

World(AccountSteps)

Given /^a logged in (user|admin)$/ do |role|
  db_create_user 'user@cb.com'
  @user.roles.create(name: role) unless role =='user'
  login(@user.email, @user.password)
end

Given(/^"(.*?)" (is|are)( a| an)?( advanced)? users?$/) do |users_list, is_or_are, a, advanced|
  users_list.split(', ').each do |user_email|
    db_create_user user_email, (advanced == ' advanced')
  end
end

Given /^"(.*?)" has an account$/ do |email|
  db_create_user email
end

Given /^a non\-registered user tries to logs in$/ do
  login('some-user', 'some-password')
end

When /^(he|she) logs in$/ do |he_or_she|
  login(@user.email, @user.password)
end

When /^(he|she) logs in with wrong password$/ do |he_or_she|
  login(@user.email, 'wrong_pass')
end

Then /^(he|she) sees a (success|fail) login message$/ do |he_or_she, login_result|
  check_login_displays_message login_result
end

Then /^he (can|can't) access the app$/ do |can_or_not|
  app_accessible(can_or_not == "can" ? true : false)
end

Given /^"([^"]*)" is logged in$/ do |email|
  GlobalVar.user_email = email unless GlobalVar.user_email == email
  visit dashboard_path
end

Given(/^registrations are open$/) do
  Kernel::silence_warnings { REGISTRATION_ACTIVE = true }
end

When(/^accessing the app$/) do
  visit root_path
end

Then(/^user is suggested to signup$/) do
  check_signup_suggested
end

When(/^he proceeds and fills the registration form$/) do
  proceed_to_signup
  fill_registration_form
end

Then(/^he has a default website prefixed with his name$/) do
  check_default_website_with_current_user_nest_name
end

When(/^he adds his "(.*?)" account$/) do |provider|
  self.send("add_#{provider}_account")
end

Then(/^"(.*?)" is marked as done$/) do |provider|
  self.send("check_#{provider}_is_done")
end

Then(/^on the background a twitter social channel is created$/) do
  db_check_twitter_channel_created
end

When(/^he finishes adding social channels$/) do
  done_adding_social_channels
end

Then(/^he is on his contents page showing no content$/) do
  current_path.should eq contents_path
  check_no_contents_displayed
end