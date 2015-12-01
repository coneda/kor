Feature: Publishments
  In order to show their user groups to friends
  Users should be able to
  Publish user groups to outside of the application
  
  
  @javascript
  Scenario: Create a Publishment
    Given I am logged in as "admin"
    And the user group "Test Group"
    When I go to the new publishment page
    Then I should see "Create published group"
    When I fill in "publishment[name]" with "Test Publishment"
    And I press "Create"
    Then I should be on the publishments page
    And I should see "Test Publishment"
    
  
  Scenario: Try to create a publishment without a name
    Given I am logged in as "admin"
    And the user group "Test Group"
    When I go to the new publishment page
    Then I should see "Create published group"
    When I fill in "publishment[name]" with ""
    And I press "Create"
    And I should see "Description has to be filled in"
