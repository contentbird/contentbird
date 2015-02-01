@account @access
Feature: User Access
  In order to protect application data
  As the site owner
  I need to register and authenticate users

Scenario: User can log in
  Given "nna@nna.com" has an account
  When he logs in
  Then he sees a success login message
  And he can access the app

Scenario: User can't log in without an account
  Given a non-registered user tries to logs in
  Then he can't access the app

Scenario: User can't log in without the right password
  Given "nna@nna.com" has an account
  When he logs in with wrong password
  Then he sees a fail login message
  And he can't access the app

@registration @javascript
Scenario: User registration
  Given registrations are open
  And "Post" content type is usable by default
  When accessing the app
  Then user is suggested to signup
  #
  When he proceeds and fills the registration form
  # Then he has a default website prefixed with his name
  #
  When he adds his "twitter" account
  Then "twitter" is marked as done
  And on the background a twitter social channel is created
  #
  When he finishes adding social channels
  Then he is on his contents page showing no content
  And a new content of type "Post" is suggested for creation