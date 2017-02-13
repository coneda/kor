Feature: Kinds
  In order to have better search criteria
  Users should be able to
  apply a kind to each entity
  

  @javascript
  Scenario: List kinds
    Given I am logged in as "admin"
    And I follow "Administration"
    And I follow "Entity types"
    Then I should see "Entity types" within "table.canvas"


  @javascript
  Scenario: create kind
    Given I am logged in as "admin"
    And I follow "Administration"
    And I follow "Entity types"
    When I click icon "plus-square"
    And I fill in "Name" with "person"
    And I fill in "Plural name" with "people"
    And I press "Save"
    Then I should see "has been created"
    When I press "close"
    Then I should see "person" within "[data-is=kor-kind-tree]"


  @javascript
  Scenario: edit kind
    Given the kind "person/people"
    Given I am logged in as "admin"
    And I follow "Administration"
    And I follow "Entity types"
    And I follow "person"
    And I fill in "Name" with "artist"
    And I fill in "Plural name" with "artists"
    And I press "Save"
    Then I should see "has been changed"
    When I press "close"
    Then I should see "artist" within "[data-is=kor-kind-tree]"
    Then I should not see "person" within "[data-is=kor-kind-tree]"


  @javascript
  Scenario: remove kind
    Given the kind "person/people"
    Given I am logged in as "admin"
    And I follow "Administration"
    And I follow "Entity types"
    And I ignore the next confirmation box
    And I click icon "remove" within "[data-is=kor-kind-tree] td:last-child"
    Then I should see "has been deleted"
    Then I should not see "person" within "[data-is=kor-kind-tree]"
    

  @javascript
  Scenario: do not show the delete link for the medium kind
    Given I am logged in as "admin"
    When I go to the kinds page
    Then I should not see "img[data-name=x]" within "table.kor_table"


  @javascript
  Scenario: Create a kind and then an entity
    Given I am logged in as "admin"
    And I follow "Administration"
    And I follow "Entity types"
    When I click icon "plus-square"
    And I fill in "Name" with "person"
    And I fill in "Plural name" with "people"
    And I press "Save"
    And I should see "has been created"
    And I press "close"
    When I select "person" from "new_entity[kind_id]"
    And I should see "Create person" within "table.canvas"
    
    
  @javascript
  Scenario: Naming should not be required for media
    Given I am logged in as "admin"
    And I go to the new "Medium-Entity" page
    Then I should not see "Name"


  @javascript
  Scenario: show multiple selected parents within the select tag
    Given the kind "Person/People"
    Given the kind "Actor/Actors"
    And the kind "Artist/Artists" inheriting from "Person,Actor"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I follow "Artist"
    Then the select "Parent type" should have value "Actor,Person"


  @javascript
  Scenario: should not show itself as possible parent
    And the kind "Artist/Artists"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I follow "Artist"
    Then "Parent type" should not have option "Artist"


  @javascript
  Scenario: create kind as child of another
    Given the kind "Person/People"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I click icon "plus-square"
    And I fill in "Name" with "Artist"
    And I fill in "Plural name" with "Artists"
    And I select "Person" from "Parent type"
    And I press "Save"
    Then I should see "has been created"
    Then kind "Artist" should have parent "Person"


  @javascript
  Scenario: move child to another parent
    Given the kind "Person/People"
    Given the kind "Actor/Actors"
    And the kind "Artist/Artists" inheriting from "Person"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I follow "Artist"
    And I unselect "Person" from "Parent type"
    And I select "Actor" from "Parent type"
    And I press "Save"
    Then I should see "has been changed"
    And kind "Artist" should have parent "Actor"
    And kind "Artist" should not have parent "Person"


  @javascript
  Scenario: add child to several parents
    Given the kind "Person/People"
    Given the kind "Actor/Actors"
    And the kind "Artist/Artists"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I follow "Artist"
    And I select "Person" from "Parent type"
    And I select "Actor" from "Parent type"
    And I press "Save"
    Then I should see "has been changed"
    And kind "Artist" should have parent "Actor"
    And kind "Artist" should have parent "Person"


  @javascript
  Scenario: display inherited fields from several parents and generations
    Given the kind "Actor/Actors"
    And the kind "Person/People" inheriting from "Actor"
    And the kind "Artist/Artists" inheriting from "Person"
    And kind "Actor/Actors" has field "activity_id" of type "Fields::String"
    And kind "Person/People" has field "gnd_id" of type "Fields::String"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I follow "Artist"
    And I follow "Fields"
    Then I should see "activity_id" within "kor-fields"


  @javascript
  Scenario: display inherited generators from several parents and generations
    Given the kind "Actor/Actors"
    And the kind "Person/People" inheriting from "Actor"
    And the kind "Artist/Artists" inheriting from "Person"
    And kind "Actor/Actors" has field "activity_id" of type "Fields::String"
    And kind "Person/People" has field "gnd_id" of type "Fields::String"
    And the generator "activity_id" for kind "Actor/Actors"
    And the generator "gnd_id" for kind "Person/People"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I follow "Artist"
    And I follow "Generators"
    Then I should see "activity_id" within "kor-generators"


  @javascript
  Scenario: prevent building circular dependencies
    Given the kind "Actor/Actors"
    And the kind "Person/People" inheriting from "Actor"
    And the kind "Artist/Artists" inheriting from "Person"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I follow "Actor"
    When I select "Artist" from "Parent type"
    And I press "Save"
    Then I should see "would result in a circular schema"
    And kind "Actor" should not have parent "Artist"


  @javascript
  Scenario: display inherited fields from the same parent just once (diamond case)
    Given the kind "Actor/Actors"
    And the kind "Person/People" inheriting from "Actor"
    And the kind "Artist/Artists" inheriting from "Actor"
    And the kind "Hero/Heroes" inheriting from "Person,Artist"
    And kind "Actor/Actors" has field "activity_id" of type "Fields::String"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I follow "Hero"
    And I follow "Fields"
    Then I should see "activity_id" exactly "1" time within "kor-fields"


  @javascript
  Scenario: display inherited generators from the same parent just once (diamond case)
    Given the kind "Actor/Actors"
    And the kind "Person/People" inheriting from "Actor"
    And the kind "Artist/Artists" inheriting from "Actor"
    And the kind "Hero/Heroes" inheriting from "Person,Artist"
    And kind "Actor/Actors" has field "activity_id" of type "Fields::String"
    And the generator "activity_id" for kind "Actor/Actors"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I follow "Hero"
    And I follow "Generators"
    Then I should see "activity_id" exactly "1" time within "kor-generators"


  @javascript
  Scenario: prohibit changing field type after creation
    Given the kind "Actor/Actors"
    And kind "Actor/Actors" has field "activity_id" of type "Fields::String"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I follow "Actor"
    And I follow "Fields"
    And I follow "activity_id"
    Then select "Type" should be disabled


  @javascript
  Scenario: add a field
    Given the kind "Actor/Actors"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I follow "Actor"
    And I follow "Fields"
    And I click icon "plus-square" within "kor-fields"
    And I select "String" from "Type"
    And I fill in "Name" with "gnd_id"
    And I fill in "Label" with "GND-ID"
    And I check "Is identifier"
    And I press "Save"
    Then I should see "has been created"
    And kind "Actor" should have field "gnd_id"


  @javascript
  Scenario: change field
    Given the kind "Actor/Actors"
    And kind "Actor/Actors" has field "activity_id" of type "Fields::String"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I follow "Actor"
    And I follow "Fields"
    And I click icon "edit" within "kor-fields"
    And I fill in "Label" with "A-ID"
    And I press "Save"
    Then I should see "has been changed"
    And kind "Actor" should have field "activity_id" with attribute "show_label" being "A-ID"


  @javascript
  Scenario: remove a field
    Given the kind "Actor/Actors"
    And kind "Actor/Actors" has field "activity_id" of type "Fields::String"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I follow "Actor"
    And I follow "Fields"
    And I ignore the next confirmation box
    And I click icon "remove" within "kor-fields"
    Then I should see "has been deleted"
    And kind "Actor" should not have field "gnd_id"


  @javascript
  Scenario: add a generator
    Given the kind "Actor/Actors"
    And kind "Actor/Actors" has field "activity_id" of type "Fields::String"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I follow "Actor"
    And I follow "Generator"
    And I click icon "plus-square" within "kor-generators"
    And I fill in "Name" with "activity_id"
    And I fill in "Generator directive" with "12345"
    And I press "Save"
    Then I should see "has been created"
    And kind "Actor" should have generator "activity_id"


  @javascript
  Scenario: change generator
    Given the kind "Actor/Actors"
    And kind "Actor/Actors" has field "activity_id" of type "Fields::String"
    And the generator "activity_id" for kind "Actor/Actors"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I follow "Actor"
    And I follow "Generator"
    And I click icon "edit" within "kor-generators"
    And I fill in "Name" with "new_activity_id"
    And I press "Save"
    Then I should see "has been changed"
    And kind "Actor" should have generator "new_activity_id"
    And kind "Actor" should not have generator "activity_id"


  @javascript
  Scenario: remove a generator
    Given the kind "Actor/Actors"
    And kind "Actor/Actors" has field "activity_id" of type "Fields::String"
    And the generator "activity_id" for kind "Actor/Actors"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I follow "Actor"
    And I follow "Generator"
    And I ignore the next confirmation box
    And I click icon "remove" within "kor-generators"
    Then I should see "has been deleted"
    And kind "Actor" should not have generator "activity_id"


  @javascript
  Scenario: create a kind and try to add a field/generator before saving
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    And I click icon "plus-square"
    And I fill in "Name" with "Artist"
    And I fill in "Plural name" with "Artists"
    Then I should not see "Fields" within "[data-is=kor-kind-editor]"
    And I should not see "Generators" within "[data-is=kor-kind-editor]"
    When I press "Save"
    Then I should see "has been created"
    And I should see "Fields" within "[data-is=kor-kind-editor]"
    And I should see "Generators" within "[data-is=kor-kind-editor]"


  @javascript
  Scenario: prevent removal of kinds when they have children
    Given the kind "Actor/Actors"
    And the kind "Person/People" inheriting from "Actor"
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Entity types"
    Then I should see icon "remove" within "[data-is=kor-kind-tree] td:nth-child(3)"
    Then I should not see icon "remove" within "[data-is=kor-kind-tree] td:nth-child(1)"
