Feature: tagging
  In order to group entities
  As an editor
  I want to tag them


  @javascript
  Scenario: Hide inplace controls without relevant rights
    # Given user "guest" is allowed to "tagging" collection "default" via credential "guests"
    Given I am logged in as "admin"
    And Mona Lisa and a medium as correctly related entities
    Given the user "guest"
    Given user "guest" is allowed to "view" collection "default" via credential "guests"
    When I follow "Abmelden"
    When I go to the entity page for "Mona Lisa"
    Then I should not see element "[kor-inplace-column] a"


  @javascript
  Scenario: Show inplace controls given the user has the rights
    Given I am logged in as "admin"
    And Mona Lisa and a medium as correctly related entities
    Given the user "guest"
    Given user "guest" is allowed to "view" collection "default" via credential "guests"
    Given user "guest" is allowed to "tagging" collection "default" via credential "guests"
    When I follow "Abmelden"
    When I go to the entity page for "Mona Lisa"
    Then I should see element "[kor-inplace-column] a"


  @javascript
  Scenario: Use inplace controls
    Given I am logged in as "admin"
    Given the entity "Mona Lisa" of kind "artwork/artworks"
    And I go to the entity page for "Mona Lisa"
    When I follow "Plus" within ".tags"
    Then I should see element ".kor-inplace-edit input"
    When I fill in "Tag list" with "smile, woman, 2d"
    And I click on the version info
    Then I should see "Tags: smile, woman, 2d"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Tags: smile, woman, 2d"


  # @javascript
  # Scenario: Use autocomplete to fill in tags