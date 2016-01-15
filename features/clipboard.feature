Feature: Clipboard
  As a user
  In order to easily handle multiple entities
  I want to have mass actions from within a clipboard
  
  
  @javascript
  Scenario: Mass relate
    Given I am logged in as "admin"
    And the entity "Mona Lisa" of kind "Werk/Werke"
    And "Mona Lisa" is selected as current entity
    And the medium "spec/fixtures/image_a.jpg"
    Then I should see "wurde angelegt"
    And all entities of kind "Medium/Media" are in the clipboard
    And the relation "stellt dar/wird dargestellt von" between "Medium/Media" and "Werk/Werke"
    When I go to the clipboard
    And I select "verknüpfen mit" from "clipboard_action"
    Then I should see "Relation"
    When I select "stellt dar" from "relation_name"
    And I press "Senden"
    When I go to the entity page for "Mona Lisa"
    Then I should see "wird dargestellt von"
    
  
  @javascript
  Scenario: Create user groups on the fly
    Given I am logged in as "admin"
    And the medium "spec/fixtures/image_a.jpg"
    And all entities of kind "Medium/Media" are in the clipboard
    And the user group "Alte Gruppe"
    When I go to the clipboard
    And I select "einer eigenen Gruppe hinzufügen" from "clipboard_action"
    And I follow "erstellen"
    And I fill in "user_group[name]" with "Neue Gruppe"
    And I press "Erstellen"
    And I select "Neue Gruppe" from "group_id"
    And I press "Senden"
    Then I should be on the user group page for "Neue Gruppe"
    And I should see element "div.kor_extended_image"


  @javascript
  Scenario: Mass relate entities
    Given I am logged in as "admin"
    And the entity "Leonardo" of kind "Person/People" 
    And the entity "Mona Lisa" of kind "Work/Works"
    And the relation "created/was created by" between "Person/People" and "Work/Works"
    When I mark "Leonardo" as current entity
    And I put "Mona Lisa" into the clipboard
    And I go to the clipboard
    When I select "verknüpfen" from "clipboard_action"
    Then I should see "alle ausgewählten Entities"
    When I press "Senden"
    Then "Leonardo" should have "created" "Mona Lisa"


  @javascript
  Scenario: Mass relate entities reversely
    Given I am logged in as "admin"
    And the entity "Leonardo" of kind "Person/People" 
    And the entity "Mona Lisa" of kind "Work/Works"
    And the relation "was created by/created" between "Work/Works" and "Person/People"
    When I mark "Leonardo" as current entity
    When I go to the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    And I put "Mona Lisa" into the clipboard
    And I go to the clipboard
    When I select "verknüpfen" from "clipboard_action"
    Then I should see "alle ausgewählten Entities"
    And I press "Senden"
    Then "Leonardo" should have "created" "Mona Lisa"

  @javascript
  Scenario: Select no entities while mass relating
    Given I am logged in as "admin"
    And the entity "Leonardo" of kind "Person/People" 
    And the entity "Mona Lisa" of kind "Work/Works"
    And the relation "was created by/created" between "Work/Works" and "Person/People"
    When I mark "Leonardo" as current entity
    When I go to the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    And I put "Mona Lisa" into the clipboard
    And I go to the clipboard
    When I uncheck the checkbox within the row for "entity" "Mona Lisa"
    When I select "verknüpfen" from "clipboard_action"
    Then I should see "alle ausgewählten Entities"
    And I press "Senden"
    Then I should not be on the 404 page

  @javascript
  Scenario: Select entities by kind
    Given I am logged in as "admin"
    And the kind "Person/People"
    And the entity "Mona Lisa" of kind "Work/Works"
    And I put "Mona Lisa" into the clipboard
    And I go to the clipboard
    And I select "Person" from "clipboard_entity_selector"
    Then the checkbox should not be checked within the row for "entity" "Mona Lisa"
    And I select "Work" from "clipboard_entity_selector"
    Then the checkbox should be checked within the row for "entity" "Mona Lisa"

