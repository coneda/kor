Feature: History
  Scenario: Use a direct link to show an entity without logging in
    When I go to the entity page for "Mona Lisa"
    Then I should see "Access denied"

  Scenario: Show an entity and then delete an other
    Given I am logged in as "admin"
    When I go to the entity page for "Mona Lisa"
    And I follow "Leonardo"
    Then I should see "Leonardo"
    When I ignore the next confirmation box
    And I follow "delete"
    Then I should be on the entity page for "Mona Lisa"
