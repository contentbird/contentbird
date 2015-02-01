@channel @messaging
Feature: Messaging channels
  In order share my content by email
  As a user
  I need to create a messaging channel and publish my content

Background:
Given "nna@nna.com" is an advanced user
And "text, memo" are basic content types
And "Post" is a usable content type owned by "the_platform" with the following content_properties
  | name | content_type |
  | body | memo         |

@javascript
Scenario: Create, Update and Delete a messaging channel
Given "nna@nna.com" is logged in
When he creates a "email" messaging channel "MailingList Co-Founders" with "ath@ath.com, seb@seb.net" as subscribers
Then the channel "MailingList Co-Founders" is created accordingly
When he edits "MailingList Co-Founders" channel
Then "MailingList Co-Founders" channel is detailed accordingly
#
When he updates the channel "MailingList Co-Founders" like this
  | action | attribute        | value                                                                       |
  | update | name             | ML Co-Founders                                                              |
  | update | baseline         | Concerns of CB fathers                                                      |
  | add    | subscriber       | thefourthguy@email.com                                                      |
  | delete | subscriber       | ath@ath.com                                                                 |
  | add    | subscriber       | ath@ath.io                                                                  |
Then channel "ML Co-Founders" is updated accordingly
#
When he deletes "ML Co-Founders" channel
Then channel is deleted

@javascript @needs_job
Scenario: Uppon publication, recipients receive an email and can unsubscribe
Given "nna@nna.com" is logged in
And he created the following "Post" contents
  | title    | author     | body                                             |
  | Why TDD? | Nico       | Because it keeps complex things simple and tidy  |
And he created a "email" messaging channel "Co Founders" with "ath@ath.io, seb@seb.net" as subscribers
When he goes and publish "Why TDD?" on "Co Founders"
Then "ath@ath.io, seb@seb.net, nna@nna.com" receive a publication email for content "Why TDD?"
#
When "ath@ath.io" unsubscribes from the received email
Then "ath@ath.io" is not in "Co Founders" mailing list
And "seb@seb.net" is in "Co Founders" mailing list