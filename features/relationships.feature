Feature: Inplace relationship editor
  Scenario: Hide the editor if user has no permissions
    And I am logged in as "jdoe"
    And I am on the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    And I should not see link "add relationship"

  Scenario: Show the editor after clicking '+'
    Given I am logged in as "admin"
    And I am on the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    And I should not see "Create relationship"
    When I click icon 'add relationship'
    Then I should see "Create relationship"

  Scenario: Click the 'Create' button without having the form completed
    Given I am logged in as "admin"
    And I am on the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    When I click icon 'add relationship'
    And I press "Save"
    And I should see "has to be filled in" within "kor-entity-selector"

  Scenario: Create a new relationship
    Given the entity "Der Schrei" of kind "work/works"
    And I am logged in as "admin"
    And I am on the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    When I click icon 'add relationship'
    And I select "is related to" from "Relation"
    And I fill in "terms" with "schrei"
    And I click "Der Schrei" within "kor-entity-selector"
    And I press "Save"
    And I should not see "Create relationship"
    Then I should see "Der Schrei" within ".relations"

  Scenario: create a second relationship
    Given the relation "is birth place of/has birth place" between "location/locations" and "person/people"
    Given I am logged in as "admin"
    And I am on the entity page for "Paris"
    When I click icon 'add relationship'
    And I select "is birth place of" from "Relation"
    And I click "Leonardo" within "kor-entity-selector"
    And I press "Save"
    And I debug
    Then I should not see "Louvre" within "kor-relation[name='is birth place of']"

  Scenario: Add properties to an existing relationship
    Given I am logged in as "admin"
    When I go to the entity page for "Paris"
    Then I should see "Louvre"
    When I click icon "edit relationship"
    And I click button "Add" within "kor-properties-editor"
    And I fill in "value" with "this is almost certain"
    And I press "Save"
    And I should not see "Edit relationship"
    And I should see "relationship has been changed"
    And I should see "this is almost certain" within "kor-relationship"

  Scenario: Delete relationship
    Given I am logged in as "admin"
    When I go to the entity page for "Paris"
    Then I should see "Louvre"
    And I ignore the next confirmation box
    When I click icon "delete relationship"
    And I should see "relationship has been deleted"
    And I should not see "Louvre" within "[data-is=kor-entity-page]"
    And I should not see "is location of"

  Scenario: Change the relation on an existing relationship
    Given the relation "is known for/provides reputation to" between "location/locations" and "institution/institutions"
    And I am logged in as "admin"
    When I go to the entity page for "Paris"
    Then I should see "Louvre"
    When I click icon "edit relationship"
    And I select "is known for" from "Relation"
    And I press "Save"
    And I should not see "Edit relationship"
    And I should see "relationship has been changed"
    And I should see "is known for" within "kor-relation"
    And I should not see "is located in" within "kor-relation"

  Scenario: Change the target entity on an existing relationship
    Given I am logged in as "admin"
    And the entity "Musée d'Orsay" of kind "institution/institutions"
    When I go to the entity page for "Paris"
    Then I should see "Louvre"
    When I click icon "edit relationship" within "kor-relationship"
    Then I should see "Edit relationship"
    And I follow "recently created"
    And I follow "Musée d'Orsay"
    And I press "Save"
    And I should not see "Edit relationship"
    And I should see "relationship has been changed"
    And I should see "is location of" within "kor-relation"
    And I should see "Musée d'Orsay" within "kor-relation"
    And I should not see "Louvre" within "kor-relation"

  Scenario: Show message when no relations are allowed for this source entity
    Given I am logged in as "admin"
    And the entity "Jean" of kind "artist/artists"
    When I go to the entity page for "Jean"
    Then I should see "Jean"
    And I click icon "add relationship"
    Then I should see "There is no relation provided for this combination of entity types"
    Given the relation "has created/has been created by" between "artist/artists" and "work/works"
    When I refresh the page
    Then I should see "Jean"
    And I click icon "add relationship"
    Then select "relation_name" should have option "is equivalent to"

  Scenario: Select a relation which should limit the choices for the other entity
    Given I am logged in as "admin"
    When I go to the entity page for "Mona Lisa"
    And I click icon "add relationship"
    And I select "is related to" from "Relation"
    Then I follow "recently created" within "kor-entity-selector"
    Then I should see "The Last Supper" within "kor-entity-selector"
    And I should not see "Louvre" within "kor-entity-selector"
    When I select "is located in" from "Relation"
    Then I follow "recently created" within "kor-entity-selector"
    Then I should not see "The Last Supper" within "kor-entity-selector"
    And I should see "Louvre" within "kor-entity-selector"

  Scenario: Select a target entity and then deselect it again
    Given I am logged in as "admin"
    And I am on the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    And I click icon "add relationship"
    And I fill in "terms" with "supper"
    And I follow "The Last Supper" within "kor-entity-selector"
    And I press "Save"
    Then I should see "has to be filled in" within "kor-relation-selector"
    And I should not see "has to be filled in" within "kor-entity-selector"
    When I follow "The Last Supper" within "kor-entity-selector"
    And I press "Save"
    And I should see "has to be filled in" within "kor-entity-selector"

  Scenario: Paginate target entities
    Given I am logged in as "admin"
    And 10 entities "artwork" of kind "work/works" inside collection "default"
    And I am on the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    And I click icon "add relationship"
    And I fill in "terms" with "supper"
    Then I should not see "artwork_7"
    When I follow "next"
    Then I should see "artwork_7"
    
  Scenario: Select another entity which should limit the choices for the relation
    Given I am logged in as "admin"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    And I click icon "add relationship"
    And I fill in "terms" with "leonardo"
    And I follow "Leonardo" within "kor-entity-selector"
    Then select "relation_name" should have option "has been created by"
    Then select "relation_name" should have no option "is related to"
    And I follow "Leonardo" within "kor-entity-selector"
    Then select "relation_name" should have option "has been created by"
    Then select "relation_name" should have option "is related to"

  Scenario: make use of the global default dating label for relations
    Given I am logged in as "admin"
    When I go to the entity page for "Paris"
    Then I should see "Louvre"
    And I click icon "add relationship"
    When I click button "Add" within "kor-datings-editor"
    Then field "Type of dating" should have value "Dating"

  Scenario: add a dating and remove it again
    Given I am logged in as "admin"
    When I go to the entity page for "Paris"
    Then I should see "Louvre"
    And I click icon "edit relationship"
    When I click button "Add" within "kor-datings-editor"
    And I fill in "Type of dating" with "first phase"
    And I fill in "Dating" with "15. Jahrhundert"
    And I press "Save"
    Then I should see "first phase: 15. Jahrhundert"
    When I click icon "edit relationship"
    And I press "delete" within "kor-datings-editor"
    And I press "Save"
    Then I should not see "first phase: 15. Jahrhundert"
    
  Scenario: add and remove a dating without closing the editor
    Given I am logged in as "admin"
    When I go to the entity page for "Paris"
    Then I should see "Louvre"
    And I click icon "edit relationship"
    When I click button "Add" within "kor-datings-editor"
    And I fill in "Type of dating" with "first phase"
    And I fill in "Dating" with "15. Jahrhundert"
    And I press "delete" within "kor-datings-editor"
    And I press "Save"
    Then I should not see "first phase: 15. Jahrhundert"

  Scenario: enter an incorrect dating string
    Given I am logged in as "admin"
    When I go to the entity page for "Paris"
    Then I should see "Louvre"
    And I click icon "edit relationship"
    When I click button "Add" within "kor-datings-editor"
    And I fill in "Type of dating" with "first phase"
    And I fill in "Dating" with "1522 perhaps?"
    And I press "Save"
    Then I should see "is invalid" within "kor-datings-editor"
