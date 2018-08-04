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
    And I should not see icon link "add relationship"

  @javascript
  Scenario: Show the editor after clicking '+'
    Given I am logged in as "admin"
    And I am on the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    And I should not see "Create relationship"
    When I click icon 'add relationship'
    Then I should see "Create relationship"

  @javascript
  Scenario: Click the 'Create' button without having the form completed
    Given I am logged in as "admin"
    And I am on the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    When I click icon 'add relationship'
    And I press "Save"
    And I should see "has to be filled in" within "kor-entity-selector"

  @javascript
  Scenario: Create a new relationship
    Given I am logged in as "admin"
    And I am on the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    When I click icon 'add relationship'
    And I select "is equivalent to" from "Relation"
    And I fill in "terms" with "schrei"
    And I click "Der Schrei" within "kor-entity-selector"
    And I press "Save"
    And I should not see "Create relationship"
    Then I should see "Der Schrei" within "kor-relationship"

  @javascript
  Scenario: Add properties to an existing relationship
    Given I am logged in as "admin"
    And the relationship "Mona Lisa" "is similar to" "Der Schrei"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    When I click icon "edit relationship"
    And I click button "Add" within "kor-properties-editor"
    And I fill in "value" with "this is almost certain"
    And I press "Save"
    And I should not see "Edit relationship"
    And I should see "relationship has been changed"
    And I should see "this is almost certain" within "kor-relationship"

  @javascript
  Scenario: Delete relationship
    Given I am logged in as "admin"
    And the relationship "Mona Lisa" "is similar to" "Der Schrei"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    And I ignore the next confirmation box
    When I click icon "delete relationship"
    And I should see "relationship has been deleted"
    And I should not see "Der Schrei" within "kor-relation"

  @javascript
  Scenario: Change the relation on an existing relationship
    Given I am logged in as "admin"
    And the relationship "Mona Lisa" "is similar to" "Der Schrei"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    When I click icon "edit relationship"
    And I select "is equivalent to" from "Relation"
    And I press "Save"
    And I should not see "Edit relationship"
    And I should see "relationship has been changed"
    And I should see "is equivalent to" within "kor-relation"
    And I should not see "is similar to" within "kor-relation"

  @javascript
  Scenario: Change the target entity on an existing relationship
    Given I am logged in as "admin"
    And the entity "The Last Supper" of kind "artwork/artworks"
    And the relationship "Mona Lisa" "is similar to" "Der Schrei"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    When I click icon "edit relationship" within "kor-relationship"
    And I follow "recently created"
    And I follow "The Last Supper"
    And I press "Save"
    And I should not see "Edit relationship"
    And I should see "relationship has been changed"
    And I should see "is similar to" within "kor-relation"
    And I should see "The Last Supper" within "kor-relation"
    And I should not see "Der Schrei" within "kor-relation"

  @javascript
  Scenario: Show message when no relations are allowed for this source entity
    Given I am logged in as "admin"
    And the entity "Leonardo" of kind "person/people"
    When I go to the entity page for "Leonardo"
    And I wait for "2" seconds
    And I click icon "add relationship"
    Then I should see "There is no relation provided for this combination of entity types"
    Given the relation "is equivalent to/is equivalent to" between "person/people" and "artwork/artworks"
    When I refresh the page
    Then I should see "Leonardo"
    And I click icon "add relationship"
    Then select "relation_name" should have option "is equivalent to"

  @javascript
  Scenario: Select a relation which should limit the choices for the other entity
    Given I am logged in as "admin"
    And the entity "Leonardo" of kind "person/people"
    And the relation "is equivalent to/is equivalent to" between "person/people" and "artwork/artworks"
    When I go to the entity page for "Mona Lisa"
    And I click icon "add relationship"
    And I select "is equivalent to" from "Relation"
    Then I follow "recently created" within "kor-entity-selector"
    Then I should see "Leonardo" within "kor-entity-selector"
    And I should see "Der Schrei" within "kor-entity-selector"
    When I select "is similar to" from "Relation"
    Then I should not see "Leonardo" within "kor-entity-selector"
    But I should see "Der Schrei" within "kor-entity-selector"

  @javascript
  Scenario: Select a target entity and then deselect it again
    Given I am logged in as "admin"
    And I am on the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    And I click icon "add relationship"
    And I fill in "terms" with "schrei"
    And I follow "Der Schrei" within "kor-entity-selector"
    And I press "Save"
    Then I should see "has to be filled in" within "kor-relation-selector"
    And I should not see "has to be filled in" within "kor-entity-selector"
    When I follow "Der Schrei" within "kor-entity-selector"
    And I press "Save"
    And I should see "has to be filled in" within "kor-entity-selector"
    
  @javascript
  Scenario: Select another entity which should limit the choices for the relation
    Given I am logged in as "admin"
    And the entity "Leonardo" of kind "person/people"
    And the relation "is equivalent to/is equivalent to" between "person/people" and "artwork/artworks"
    When I go to the entity page for "Mona Lisa"
    And I click icon "add relationship"
    And I fill in "terms" with "leonardo"
    And I follow "Leonardo"
    Then select "relation_name" should have no option "is similar to"
    Then select "relation_name" should have option "is equivalent to"
    And I follow "Leonardo"
    Then select "relation_name" should have option "is similar to"
    Then select "relation_name" should have option "is equivalent to"

  @javascript
  Scenario: make use of the default dating label for relations
    Given I am logged in as "admin"
    And the relationship "Mona Lisa" "is similar to" "Der Schrei"
    When I go to the entity page for "Mona Lisa"
    And I click icon "add relationship"
    When I click button "Add" within "kor-datings-editor"
    Then field "Type of dating" should have value "Dating"

  @javascript
  Scenario: add a dating
    Given I am logged in as "admin"
    And the relationship "Mona Lisa" "is similar to" "Der Schrei"
    When I go to the entity page for "Mona Lisa"
    And I click icon "edit relationship"
    When I click button "Add" within "kor-datings-editor"
    And I fill in "Type of dating" with "first phase"
    And I fill in "Dating" with "15. Jahrhundert"
    And I press "Save" within "w-modal"
    Then I should see "first phase: 15. Jahrhundert" within "kor-relationship"

  @javascript
  Scenario: remove a dating
    Given I am logged in as "admin"
    And the relationship "Mona Lisa" "is similar to" "Der Schrei"
    And the relationship has a dating "Datierung|1888"
    When I go to the entity page for "Mona Lisa"
    And I click icon "edit relationship"
    And I press "remove" within "kor-datings-editor"
    And I press "Save" within "w-modal"
    Then I should not see "Datierung: 1888"


  @javascript
  Scenario: add and remove a dating without reloading the page
    Given I am logged in as "admin"
    And the relationship "Mona Lisa" "is similar to" "Der Schrei"
    When I go to the entity page for "Mona Lisa"
    And I click icon "edit relationship"
    When I click button "Add" within "kor-datings-editor"
    And I fill in "Type of dating" with "first phase"
    And I fill in "Dating" with "15. Jahrhundert"
    And I press "Save" within "w-modal"
    Then I should see "first phase: 15. Jahrhundert"
    And I click icon "edit relationship"
    And I press "remove" within "kor-datings-editor"
    And I press "Save" within "w-modal"
    Then I should not see "Datierung: 1888"

  @javascript
  Scenario: add and remove a dating without closing the editor
    Given I am logged in as "admin"
    And the relationship "Mona Lisa" "is similar to" "Der Schrei"
    When I go to the entity page for "Mona Lisa"
    And I click icon "edit relationship"
    When I click button "Add" within "kor-datings-editor"
    And I fill in "Type of dating" with "first phase"
    And I fill in "Dating" with "15. Jahrhundert"
    And I press "remove" within "kor-datings-editor"
    And I press "Save" within "w-modal"
    Then I should not see "Datierung: 1888"

  @javascript
  Scenario: enter an incorrect dating string
    Given I am logged in as "admin"
    And the relationship "Mona Lisa" "is similar to" "Der Schrei"
    When I go to the entity page for "Mona Lisa"
    And I click icon "edit relationship"
    When I click button "Add" within "kor-datings-editor"
    And I fill in "Dating" with "1522 perhaps?"
    And I press "Save"
    Then I should see "is invalid" within "kor-datings-editor"
