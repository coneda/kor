# TODO: move this to relationships.feature

Feature: Inplace relationship editor

  Background:
    Given the entity "Mona Lisa" of kind "artwork/artworks"
    And the entity "Der Schrei" of kind "artwork/artworks"
    And the relation "is equivalent to/is equivalent to" between "artwork/artwork" and "artwork/artworks"
    And the relation "is similar to/is similar to" between "artwork/artwork" and "artwork/artworks"

  @javascript
  Scenario: Hide the editor if user has no permissions
    Given user "jdoe" is allowed to "view" collection "default" via credential "users"
    And I am logged in as "jdoe"
    And I am on the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    And I should not see element "img.kor_command_image[data-name='plus']"

  @javascript
  Scenario: Show the editor after clicking '+'
    Given I am logged in as "admin"
    And I am on the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    And I should not see "Create link"
    When I follow "plus"
    Then I should see "Create link"

  @javascript
  Scenario: Click the 'Create' button without having the form completed
    Given I am logged in as "admin"
    And I am on the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    When I follow "plus"
    And I press "Save"
    Then I should see "Relation has to be filled in" within ".kor-errors"
    And I should see "Target has to be filled in" within ".kor-errors"

  Scenario: Create a new relationship
  Scenario: Add properties to an existing relationship

  Scenario: Select a relation which should limit the choices for the other entity
  Scenario: Select another entity which should limit the choices for the relation