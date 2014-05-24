Feature: History
  In order to save time
  Users should be able to
  return to the previous page when performing certain actions


  @javascript
  Scenario: Show an entity and then delete an other
    Given I am logged in as "admin"
    And Leonardo, Mona Lisa and a medium as correctly related entities
    When I go to the entity page for "Mona Lisa"
    And I follow "Leonardo da Vinci"
    And I wait for "2" seconds
    And I ignore the next confirmation box
    And I follow "X" within ".layout_panel.top:first-child"
    Then I should be on the entity page for "Mona Lisa"
  

  @javascript
  Scenario: Put an entity into the clipboard and return to that entity
    Given I am logged in as "admin"
    And the entity "Nürnberg" of kind "Ort/Orte"
    And I am on the entity page for "Nürnberg"
    And I wait for "2" seconds
    When I follow "Target"
    Then I should be on the entity page for "Nürnberg"
