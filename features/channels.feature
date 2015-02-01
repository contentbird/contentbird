@channel
Feature: Manage channels
  In order publish my content
  As a user
  I need to create, edit and delete channels

Background:
Given "nna@nna.com" is an advanced user
And "text, memo" are basic content types
And "Car" is a content type owned by "nna@nna.com" with the following content_properties
  | name         | content_type |
  | constructor  | text         |
And "Post" is a usable content type owned by "the_platform" with the following content_properties
  | name | content_type |
  | body | memo         |

@javascript
Scenario: Create, Update and Delete a website channel
Given "nna@nna.com" is logged in
When he creates a new website channel "My website" with prefix "nnablog" and the following sections
  | format | mode     | title    | forewords                               |
  | Post   | display  | My Posts | This is what I think about the world... |
  | Post   | form     | Suggest  | Suggest me some posts                   |
Then the channel "My website" is created accordingly
When he edits "My website" channel
Then "My website" channel is detailed accordingly

When he updates the channel "My website" like this
  | action | attribute        | value                                                                       |
  | update | name             | My new website                                                              |
  | update | baseline         | This is my ws channel                                                       |
  | add    | section          | format=Car&mode=display&title=Favorite cars&forewords=My all time favorites |
  | update | section_suggest  | format=Car&forewords=Suggest me some cars                                   |
  | delete | section_my-posts |                                                                             |
Then channel "My new website" is updated accordingly
#
When he deletes "My new website" channel
Then channel is deleted