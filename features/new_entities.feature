Feature: New entities
  Scenario: List new entities
    Given I am logged in as "admin"
    When I follow "New entities"
    Then I should see "Mona Lisa"
    When I follow "Mona Lisa"
    Then I should be on the entity page for "Mona Lisa"