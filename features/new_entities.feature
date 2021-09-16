Feature: New entities
  Scenario: List new entities
    Given I am logged in as "admin"
    When I follow "New entities"
    And I fill in "created_after" with '2016-10-19'
    And I fill in "updated_after" with "2016-10-20"
    And I fill in "Created by" with "rossi"
    Then I should see "Mario Rossi"
    When I select autocomplete option "Mario Rossi"
    Then I should not see "Leonardo"
    Then I should see "The Last Supper"
    When I follow "The Last Supper"
    Then I should be on the entity page for "The Last Supper"
    