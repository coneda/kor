Feature: History
  Scenario: Use a direct link to show an entity without logging in
    When I go to the entity page for "Mona Lisa"
    Then I should see "Access denied"

  Scenario: Show an entity and then delete an other
    Given I am logged in as "admin"
    When I go to the entity page for "Mona Lisa"
    And I follow "Leonardo"
    Then I should see "Leonardo"
    And I should see "person"
    When I ignore the next confirmation box
    And I follow "delete"
    Then I should be on the entity page for "Mona Lisa"

  Scenario: Put an entity into the clipboard and return to that entity
    Given I am logged in as "admin"
    And the entity "Nürnberg" of kind "Ort/Orte"
    And I am on the entity page for "Nürnberg"
    And I wait for "2" seconds
    When I click "add to clipboard"
    Then I should be on the entity page for "Nürnberg"

  @notravis
  Scenario: Back button on denied page
    And I am on the home page
    When I follow "New entries"
    Then I should see "No entities found"
    When I go to the entity page for "Paris"
    Then I should see "Access denied"
    When I follow "back"
    Then I should see "No entities found"
