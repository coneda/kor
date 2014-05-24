Feature: User administration
  In order to limit access to certain users
  As a user admin
  I should be able to administer users
  

  @javascript
  Scenario: Delete a user
    Given I am logged in as "admin"
    And the user "john"
    When I go to the users page
    And I follow the delete link within the row for "user" "john"
    Then there should be no "user" named "john"
    Then I should be on the users page
    

  Scenario: Have a sorted list of credentials within the user form
    Given I am logged in as "admin"
    And the credential "AAAs"
    When I go to the users page
    And I follow "Plus"
    Then I should see "AAAs" before "Administrators"

