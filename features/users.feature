Feature: User administration
  Scenario: Delete a user who has shared user groups
    Given I am logged in as "admin"
    And "jdoe" has a shared user group "My Group"
    When I go to the users page
    And I ignore the next confirmation box
    When I follow "delete" within the row for user "John Doe"
    Then I should be on the users page
    And I should not see "John Doe"
    Then there should be no "UserGroup" named "My Group"
    
  Scenario: Have a sorted list of credentials within the user form
    Given I am logged in as "admin"
    And the credential "AAAs"
    When I go to the users page
    And I follow "add"
    Then I should see "Create user"
    And I should see "AAAs" before "admins"

  Scenario: Show the user's API key
    Given I am logged in as "admin"
    And I go to the users page
    When I follow "edit" within the row for user "John Doe"
    Then I should see "jdoe"'s API Key

  Scenario: Accept terms of use
    Given the user "jdoe" has not accepted the terms of use
    And I am logged in as "jdoe"
    Then I should see "Terms of use"
    When I follow "accept terms"
    Then I should see "You have accepted the terms of use"

  Scenario: Reset a user's password
    Given I am logged in as "admin"
    And I follow "Users"
    And I ignore the next confirmation box
    And I follow "reset password" within the row for user "jdoe"
    Then I should see "has been reset"
