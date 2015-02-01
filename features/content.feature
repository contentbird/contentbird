@content
Feature: Manage contents
  In order produce content
  As a user
  I need to create, edit and delete contents

Background:
Given "nna@nna.com" is a user
And "text, memo, image" are basic content types
And "Car" is a content type owned by "nna@nna.com" with the following content_properties
  | name         | content_type |
  | constructor  | text         |
  | side_view    | image        |
And "Post" is a usable content type owned by "the_platform" with the following content_properties
  | name | content_type |
  | body | memo         |

@javascript
Scenario: Create, Update and Delete a content
Given "nna@nna.com" is logged in
When he creates a new "Car" content with the following properties
 | title        | constructor | side_view       |
 | My deudeuche | citroen     | Citroen_2CV.jpg |
Then the content "My deudeuche" is created accordingly
When he edits "My deudeuche" content
Then "My deudeuche" content is detailed accordingly
#
When he updates the content "My deudeuche" like this
  | property    | new_value       |
  | title       | My jacky deuche |
  | constructor | Jacky           |
Then content "My jacky deuche" is updated accordingly
#
When he deletes "My jacky deuche" content
Then content is deleted

@javascript
Scenario: List, filter and search contents owned by user or available by default
Given "nna@nna.com" is logged in
And he created the following "Car" contents
 | title   | constructor |
 | Model S | Tesla       |
 | Veyron  | Bugatti     |
And he created the following "Post" contents
 | title               | body                    |
 | Model Driven Design | this is how you do ...  |
When he opens the "Content" menu
Then contents "Model S, Veyron, Model Driven Design" are listed
#
When he filters "Car" content types
Then contents "Model S, Veyron" are listed
#
When he searches for "Model" content type
Then content "Model S" is listed