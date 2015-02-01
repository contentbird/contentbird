@content
Feature: Add and Publish content by sending an email to contentbird
  In order to have more contents
  As a user
  I must be able to create and publish my content by sending an email

Background:
Given "nna@nna.com" is a user
And "text, memo, url" are basic content types
And "Link" is a usable content type owned by "the_platform" with the following content_properties
  | name    | content_type |
  | url     | url          |
  | comment | text         |

@javascript
Scenario: Add link by sending an email
Given "nna@nna.com" sends an email to "me@cbird.me" with the following content
| subject                | body                                                                |
| heroku is a great PAAS | http://www.heroku.com \nI've been using it for years and it's great |
When he logs in
And he opens the "Content" menu
Then content "heroku is a great PAAS" is listed
When he edits "heroku is a great PAAS" content
Then "heroku is a great PAAS" content is detailed like this
| title                  | url                   | comment                                     |
| heroku is a great PAAS | http://www.heroku.com | I've been using it for years and it's great |
