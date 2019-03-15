Feature: New entities
  Scenario: List new entities
    Given I am logged in as "admin"
    When I follow "New entities"
    And I fill in "created_after" with '2016-10-19'
    And I fill in "updated_after" with "2016-10-20"
    And I fill in "Created by" with "rossi"
    And I follow "Mario Rossi"
    Then I should not see "Leonardo"
    And I debug
    Then I should see "Mona Lisa"
    When I follow "Mona Lisa"
    Then I should be on the entity page for "Mona Lisa"