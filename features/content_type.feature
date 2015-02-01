@content_type
Feature: Manage content types
  In order to handle all type of content
  As a user
  I need to create, edit and delete content_types

Background:
Given "nna@nna.com, ath@ath.com" are advanced users
And "text, memo, image" are basic content types
And the following user content types
  | name  | owner        |
  | car   | nna@nna.com  |
  | book  | ath@ath.com  |

@javascript
Scenario: List content_types owned by user
Given "nna@nna.com" is logged in
When he opens the "Format" menu
Then content_type "car" is listed
And content_type "book" is not listed

@javascript
Scenario: Create, Update and Delete a content_type
Given "ath@ath.com" is logged in
When he creates a new content_type "recipe" with the following content_properties
  | name         | content_type |
  | cooking time | text         |
  | process      | memo         |
Then the content_type "recipe" is created
When he edits "recipe" content_type
Then "recipe" content_type is detailed
#
When he updates the content_type "recipe" like this
  | action | name         | new_name         | new_content_type |
  | update | process      | how_to           | text             |
  | add    |              | duration         | text             |
  | delete | cooking time |                  |                  |
Then content_type "recipe" is updated like described
#
When he deletes "recipe" content_type
Then content_type is deleted