Feature: Kinds
  Scenario: List kinds
    Given I am logged in as "admin"
    And I follow "Entity types"
    Then I should see "Entity types" within ".w-content"

  Scenario: create kind
    Given I am logged in as "admin"
    And I follow "Entity types"
    When I follow "add"
    And I fill in "Name" with "literature"
    And I fill in "Plural name" with "literature"
    And I check "Activate tagging for this entity type"
    And I fill in "Default label for datings" with "Publication date"
    And I fill in "Label for the entity name" with "Title"
    And I fill in "Label for the distinct name" with "Subtitle"
    And I press "Save"
    Then I should see "has been created"
    When I follow "back to list"
    Then I should see "literature" within widget "kor-kinds"
    When I follow "edit" within the row for kind "literature"
    Then field "Default label for datings" should have value "Publication date"

  Scenario: edit kind
    Given I am logged in as "admin"
    And I follow "Entity types"
    And I follow "person"
    And I fill in "Name" with "artist"
    And I fill in "Plural name" with "artists"
    And I press "Save"
    Then I should see "has been changed"
    When I follow "back to list"
    Then I should see "artist" within widget "kor-kinds"
    Then I should not see "person" within widget "kor-kinds"

  Scenario: remove kind
    Given the kind "literature/literature"
    Given I am logged in as "admin"
    And I follow "Entity types"
    And I ignore the next confirmation box
    And I follow "delete" within the row for kind "literature"
    Then I should see "has been deleted"
    Then I should not see "literature" within widget "kor-kinds"

  Scenario: do not show the delete link for the medium kind
    Given I am logged in as "admin"
    And I follow "Entity types"
    Then I should not see link "delete" within the row for kind "medium"

  Scenario: Create a kind and then an entity
    Given I am logged in as "admin"
    And I follow "Entity types"
    When I follow "add"
    And I fill in "Name" with "literature"
    And I fill in "Plural name" with "literature"
    And I press "Save"
    And I should see "has been created"
    And I follow "back to list"
    And I select "literature" from "new_entity_type"
    And I should see "Create literature"
    
  Scenario: Naming should not be required for media
    Given I am logged in as "admin"
    And I go to the entity page for the first medium
    And I follow "edit"
    Then I should not see "Name"

  Scenario: show multiple selected parents within the select tag
    Given the kind "actor/actors"
    And the kind "artist/artists" inheriting from "person,actor"
    And I am logged in as "admin"
    And I follow "Entity types"
    And I follow "artist"
    Then the select "Parent type" should have value "actor,person"

  Scenario: should not show itself as possible parent
    And I am logged in as "admin"
    And I follow "Entity types"
    And I follow "person"
    Then "Parent type" should not have option "person"

  Scenario: create kind as child of another
    And I am logged in as "admin"
    And I follow "Entity types"
    And I follow "add"
    And I fill in "Name" with "artist"
    And I fill in "Plural name" with "artists"
    And I select "person" from "Parent type"
    And I press "Save"
    Then I should see "has been created"
    Then kind "artist" should have parent "person"

  Scenario: move child to another parent
    Given the kind "actor/actors"
    And the kind "artist/artists" inheriting from "person"
    And I am logged in as "admin"
    And I follow "Entity types"
    And I follow "artist"
    And I unselect "person" from "Parent type"
    And I select "actor" from "Parent type"
    And I press "Save"
    Then I should see "has been changed"
    And kind "artist" should have parent "actor"
    And kind "artist" should not have parent "person"

  Scenario: add child to several parents
    Given the kind "actor/actors"
    And the kind "artist/artists"
    And I am logged in as "admin"
    And I follow "Entity types"
    And I follow "artist"
    And I select "person" from "Parent type"
    And I select "actor" from "Parent type"
    And I press "Save"
    Then I should see "has been changed"
    And kind "artist" should have parent "actor"
    And kind "artist" should have parent "person"

  Scenario: prevent building circular dependencies
    Given the kind "actor/actors"
    And the kind "person/people" inheriting from "actor"
    And the kind "artist/artists" inheriting from "person"
    And I am logged in as "admin"
    And I follow "Entity types"
    And I follow "actor"
    When I select "artist" from "Parent type"
    And I press "Save"
    Then I should see "would result in a circular schema"
    And kind "actor" should not have parent "artist"

  Scenario: prohibit changing field type after creation
    Given the kind "actor/actors"
    And kind "actor/actors" has field "activity_id" of type "Fields::String"
    And I am logged in as "admin"
    And I follow "Entity types"
    And I follow "actor"
    And I follow "activity_id" within widget "kor-fields"
    Then select "Type" should be disabled

  Scenario: add a field
    And I am logged in as "admin"
    And I follow "Entity types"
    And I follow "person"
    And I follow "add" within widget "kor-fields"
    Then I should see "Create field"
    And I select "string" from "Type"
    And I fill in "Name" with "viaf_id"
    And I fill in "Label" with "VIAF-ID"
    And I check "Is identifier"
    And I press "Save"
    Then I should see "has been created"
    And kind "person" should have field "viaf_id"

  Scenario: change field
    And I am logged in as "admin"
    And I follow "Entity types"
    And I follow "person"
    And I follow "edit" within the row for field "wikidata_id"
    And I fill in "Label" with "WikiData-ID"
    And I press "Save"
    Then I should see "has been changed"
    And kind "person" should have field "wikidata_id" with attribute "show_label" being "WikiData-ID"

  Scenario: remove a field
    And I am logged in as "admin"
    And I follow "Entity types"
    And I follow "person"
    And I ignore the next confirmation box
    And I follow "delete" within the row for field "wikidata_id"
    Then I should see "has been deleted"
    And kind "person" should not have field "wikidata_id"

  Scenario: add and render a generator
    And I am logged in as "admin"
    And I follow "Entity types"
    And I follow "person"
    And I follow "add" within widget "kor-generators"
    Then I should see "Create generator"
    Then I should see "Edit person"
    And I fill in "Name" with "activity_id"
    And I fill in "Generator directive" with "<span>12345</span>"
    And I press "Save"
    Then I should see "has been created"
    And kind "person" should have generator "activity_id"
    When I go to the entity page for "Leonardo"
    Then I should see "12345"

  Scenario: change generator
    And I am logged in as "admin"
    And I follow "Entity types"
    And I follow "person"
    And I follow "edit" within the row for generator "gnd"
    Then I should see "Edit generator"
    And I fill in "Name" with "new_activity_id"
    And I press "Save"
    Then I should see "has been changed"
    And kind "person" should have generator "new_activity_id"
    And kind "person" should not have generator "activity_id"

  Scenario: remove a generator
    And I am logged in as "admin"
    And I follow "Entity types"
    And I follow "person"
    And I ignore the next confirmation box
    And I follow "delete" within the row for generator "gnd"
    Then I should see "has been deleted"
    And kind "person" should not have generator "gnd"

  Scenario: create a kind and try to add a field/generator before saving
    And I am logged in as "admin"
    And I follow "Entity types"
    And I follow "add"
    And I fill in "Name" with "artist"
    And I fill in "Plural name" with "artists"
    Then I should not see "Fields" within "[data-is=kor-kind-editor]"
    And I should not see "Generators" within "[data-is=kor-kind-editor]"
    When I press "Save"
    Then I should see "has been created"
    And I should see "Fields" within "[data-is=kor-kind-editor]"
    And I should see "Generators" within "[data-is=kor-kind-editor]"

  Scenario: prevent removal of kinds when they have children
    Given the kind "actor/actors"
    And the kind "artist/artists" inheriting from "actor"
    And I am logged in as "admin"
    And I follow "Entity types"
    Then I should not see link "delete" within the row for kind "actor"
    Then I should see link "delete" within the row for kind "artist"

  Scenario: prevent removal of kinds when they have entities
    Given the kind "actor/actors"
    And I am logged in as "admin"
    And I follow "Entity types"
    Then I should not see link "delete" within the row for kind "person"
    Then I should see link "delete" within the row for kind "actor"
    