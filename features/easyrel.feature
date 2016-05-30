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
    When I click element "[data-name=plus]" within ".relationships"
    Then I should see "Create link"

  @javascript
  Scenario: Click the 'Create' button without having the form completed
    Given I am logged in as "admin"
    And I am on the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    When I click element "[data-name=plus]" within ".relationships"
    And I press "Save"
    Then I should see "Relation has to be filled in" within ".kor-errors"
    And I should see "Target has to be filled in" within ".kor-errors"

  @javascript
  Scenario: Create a new relationship
    Given I am logged in as "admin"
    And I am on the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    When I click element "[data-name=plus]" within ".relationships"
    And I select "is equivalent to" from "relation_name"
    And I fill in "terms" with "schrei"
    And I click element "[kor-id='2']"
    And I press "Save"
    And I should not see "Create link"
    Then I should see "Der Schrei" within ".relationship"

  @javascript
  Scenario: Add properties to an existing relationship
    Given I am logged in as "admin"
    And the relationship "Mona Lisa" "is similar to" "Der Schrei"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    When I click element "[data-name=pen]" within ".relationships"
    And I click button "Add" within ".relationships"
    And I fill in ".properties > .input-with-button:first-child input" with "this is almost certain"
    And I press "Save"
    And I should not see "Edit link"
    And I should see "Relationship has been changed"
    And I should see "this is almost certain" within ".relationships"

  @javascript
  Scenario: Delete relationship
    Given I am logged in as "admin"
    And the relationship "Mona Lisa" "is similar to" "Der Schrei"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    And I ignore the next confirmation box
    When I click element "[data-name=x]" within ".relationships"
    And I should see "Relationship has been deleted"
    And I should not see "Der Schrei" within ".relationships"

  @javascript
  Scenario: Change the relation on an existing relationship
    Given I am logged in as "admin"
    And the relationship "Mona Lisa" "is similar to" "Der Schrei"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    When I click element "[data-name=pen]" within ".relationships"
    And I select "is equivalent to" from "relation_name"
    And I press "Save"
    And I should not see "Edit link"
    And I should see "Relationship has been changed"
    And I should see "is equivalent to" within ".relationships"
    And I should not see "is similar to" within ".relationships"

  @javascript
  Scenario: Change the target entity on an existing relationship
    Given I am logged in as "admin"
    And the entity "The Last Supper" of kind "artwork/artworks"
    And the relationship "Mona Lisa" "is similar to" "Der Schrei"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    When I click element "[data-name=pen]" within ".relationships"
    And I follow "recently created"
    And I click on entity "The Last Supper"
    And I press "Save"
    And I should not see "Edit link"
    And I should see "Relationship has been changed"
    And I should see "is similar to" within ".relationships"
    And I should see "The Last Supper" within ".relationships"
    And I should not see "Der Schrei" within ".relationships"

  @javascript
  Scenario: Show message when no relations are allowed for this source entity
    Given I am logged in as "admin"
    And the entity "Leonardo" of kind "person/people"
    When I go to the entity page for "Leonardo"
    And I wait for "2" seconds
    And I click element "[data-name=plus]" within ".relationships"
    Then I should see "There is no relation provided for this combination of entity types"
    Given the relation "is equivalent to/is equivalent to" between "person/people" and "artwork/artworks"
    When I refresh the page
    Then I should see "Leonardo"
    When I click element "img[data-name=plus]"
    Then I should see "is equivalent to" within "[kor-relation-selector]"

  @javascript
  Scenario: Select a relation which should limit the choices for the other entity
    Given I am logged in as "admin"
    And the entity "Leonardo" of kind "person/people"
    And the relation "is equivalent to/is equivalent to" between "person/people" and "artwork/artworks"
    When I go to the entity page for "Mona Lisa"
    And I click element "[data-name=plus]" within ".relationships"
    And I select "is equivalent to" from "relation_name"
    Then I follow "recently created" within "[kor-entity-selector]"
    Then I should see "Leonardo" within "[kor-entity-selector]"
    And I should see "Der Schrei" within "[kor-entity-selector]"
    When I select "is similar to" from "relation_name"
    Then I should not see "Leonardo" within "[kor-entity-selector]"
    But I should see "Der Schrei" within "[kor-entity-selector]"

  @javascript
  Scenario: Select a target entity and then deselect it again
    Given I am logged in as "admin"
    And I am on the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    When I click element "[data-name=plus]" within ".relationships"
    And I fill in "terms" with "schrei"
    And I click element "[kor-id='2']"
    And I press "Save"
    Then I should see "Relation has to be filled in" within ".kor-errors"
    And I should not see "Target has to be filled in" within ".kor-errors"
    When I click element "[kor-id='2']" again
    And I press "Save"
    Then I should see "Relation has to be filled in" within ".kor-errors"
    And I should see "Target has to be filled in" within ".kor-errors"
    
  @javascript
  Scenario: Select another entity which should limit the choices for the relation
    Given I am logged in as "admin"
    And the entity "Leonardo" of kind "person/people"
    And the relation "is equivalent to/is equivalent to" between "person/people" and "artwork/artworks"
    When I go to the entity page for "Mona Lisa"
    And I click element "[data-name=plus]" within ".relationships"
    And I fill in "terms" with "leonardo"
    And I click element "[kor-id='3']"
    Then I should not see "is similar to" within "[kor-relation-selector]"
    And I should see "is equivalent" within "[kor-relation-selector]"
    When I wait for "2" second
    And I click element "[kor-id='3']" again
    Then I should see "is similar to" within "[kor-relation-selector]"
    And I should see "is equivalent" within "[kor-relation-selector]"

