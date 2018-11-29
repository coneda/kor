Feature: Publishments
  Scenario: Create a Publishment
    Given I am logged in as "admin"
    And the user group "Test Group"
    When I go to the new publishment page
    Then I should see "Create published group"
    When I fill in "Name" with "Test Publishment"
    And I press "Save"
    Then I should be on the publishments page
    And I should see "Test Publishment"
  
  Scenario: Validations (enter no name)
    Given I am logged in as "admin"
    And the user group "Test Group"
    When I go to the new publishment page
    Then I should see "Create published group"
    When I fill in "Name" with ""
    And I press "Save"
    And I should see "has to be filled in"
