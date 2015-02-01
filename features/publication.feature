@publication
Feature: Publish and unpublish content across channels
  In order to handle my privacy
  As a user
  I need to pusblish and unpublish my content at will across my channels, with or without time limit

Background:
Given "nna@nna.com" is a user
And "text, memo" are basic content types
And "Post" is a usable content type owned by "the_platform" with the following content_properties
  | name   | content_type |
  | author | text         |
  | body   | memo         |
And "nna@nna.com" is logged in
And he created the following "Post" contents
  | title    | author     | body                                             |
  | Why TDD? | Nico       | Because it keeps complex things simple and tidy  |
  | Refactor | Adrien     | Only you need a good test suite first            |
And he created the following social channels
  | name    | url_prefix  |
  | Friends | nna-friends |
  | Foes    | nna-foes    |

@javascript
Scenario: I can publish and unpublish contents to social channels
When he opens the "Content" menu
Then he sees content "Why TDD?" has 0 publication
And he sees content "Refactor" has 0 publication

When he unfolds publications for content "Why TDD?"
Then he sees the following publications
| channel | published | expire_in  |
| Friends | no        | never      |
| Foes    | no        | never      |

When he publishes it to channel "Friends"
Then he sees the following publications
| channel | published | expire_in  |
| Friends | yes       | never      |
| Foes    | no        | never      |

When he publishes it to channel "Foes"
Then he sees the following publications
| channel | published | expire_in  |
| Friends | yes       | never      |
| Foes    | yes       | never      |

When he unpublishes it from channel "Friends"
Then he sees the following publications
| channel | published | expire_in  |
| Friends | no        | never      |
| Foes    | yes       | never      |

When he unfolds publications for content "Refactor"
And he publishes it to channel "Friends"
Then he sees the following publications
| channel | published | expire_in  |
| Friends | yes       | never      |
| Foes    | no        | never      |

When he goes to see the details of content "Why TDD?"
Then he sees the current content has 1 publication
And he sees the following publications
| channel | published | expire_in  |
| Friends | no        | never      |
| Foes    | yes       | never      |

When he publishes it to channel "Friends"
Then he sees the current content has 2 publications
And he sees the following publications
| channel | published | expire_in  |
| Friends | yes       | never      |
| Foes    | yes       | never      |


@javascript
Scenario: I can set time limits to my publications
When he opens the "Content" menu
When he unfolds publications for content "Why TDD?"
And he publishes it to channel "Friends"
And he publishes it to channel "Foes"

Then he successfully expires its channel "Friends" publication from never to 1 day
Then he successfully expires its channel "Friends" publication from 1 day to 1 month
Then he successfully expires its channel "Foes" publication from never to 1 week
Then he successfully expires its channel "Friends" publication from 1 month to 1 week

When he unpublishes it from channel "Friends"
And he publishes it to channel "Friends" again
Then he sees the following publications
| channel | published | expire_in  |
| Friends | yes       | never      |
| Foes    | yes       | week       |

When he goes to see the details of content "Why TDD?"
And he sees the following publications
| channel | published | expire_in  |
| Friends | yes       | never      |
| Foes    | yes       | week       |

Then he successfully expires its channel "Foes" publication from 1 week to never
And he sees the following publications
| channel | published | expire_in  |
| Friends | yes       | never      |
| Foes    | yes       | never      |


@javascript
Scenario: Unpublish and set expirations from Channel show
Given he created the following "Post" contents
| title       | author     | body                          |
| How to code | Nico       | This is what you should do... |
And he created the following publications
| channel  | content     | expire_in |
| Friends  | Why TDD?    | never     |
| Friends  | Refactor    | month     |
| Friends  | How to code | week      |

When he proceeds to "Friends" channel
Then he sees the channel has only these publications
| content     | expire_in  |
| Why TDD?    | never      |
| Refactor    | month      |
| How to code | week       |

When he successfully expires its content "Why TDD?" publication from never to 1 day
And he successfully expires its content "Refactor" publication from 1 month to 1 week
And he unpublishes "How to code"

Then he sees the channel has only these publications
| content     | expire_in   |
| Why TDD?    | day         |
| Refactor    | week        |
| How to code | unpublished |