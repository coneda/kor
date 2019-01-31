Feature: History
  In order to save time
  Users should be able to
  return to the previous page when performing certain actions


  @javascript
  Scenario: Use a direct link to show an entity without logging in
    Given the entity "Mona Lisa" of kind "Werk/Werke"
    When I go to the entity page for "Mona Lisa"
    And I reload the page
    Then I should see "Access denied"


  @javascript
  Scenario: Show an entity and then delete an other
    Given I am logged in as "admin"
    And Leonardo, Mona Lisa and a medium as correctly related entities
    When I go to the entity page for "Mona Lisa"
    And I follow the link with text "Leonardo da Vinci"
    Then I should see "Leonardo da Vinci"
    When I ignore the next confirmation box
    And I wait for "2" seconds
    And I follow "X" within ".layout_panel.top:first-child"
    Then I should be on the entity page for "Mona Lisa"
  

  @javascript
  Scenario: Put an entity into the clipboard and return to that entity
    Given I am logged in as "admin"
    And the entity "Nürnberg" of kind "Ort/Orte"
    And I am on the entity page for "Nürnberg"
    And I wait for "2" seconds
    When I click element "a[kor-to-clipboard]"
    Then I should be on the entity page for "Nürnberg"


  @javascript @notravis
  Scenario: Back button on denied page
    Given the entity "Paris" of kind "Ort/Orte"
    And I am on the welcome page
    When I follow "New entries"
    Then I should see "No entries found"
    When I go to the entity page for "Paris"
    Then I should see "Access denied"
    When I follow "back"
    Then I should see "No entries found"
