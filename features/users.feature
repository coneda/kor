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
    And the user "jdoe"
    And I go to the users page
    When I follow "edit" within the row for user "John Doe"
    Then I should see "jdoe"'s API Key

  Scenario: Send no email to a newly created user
    Given I am logged in as "admin"
    And I go to the users page
    And I follow "add"
    And I fill in "Username" with "hmustermann"
    And I fill in "E-mail" with "hmustermann@example.com"
    And I press "Save"
    Then I should see "hmustermann has been created"
    And no email should have been sent

  Scenario: Send email to newly created user (when told to do so)
    Given I am logged in as "admin"
    And I go to the users page
    And I follow "add"
    And I fill in "Username" with "hmustermann"
    And I fill in "E-mail" with "hmustermann@example.com"
    And I fill in "Password" with "hmustermann"
    And I fill in "Repeat password" with "bla"
    And I check "Active"
    And I press "Save"
    Then I should see "does not match"
    When I fill in "Repeat password" with "hmustermann"
    And I check "Send notification and access information to user"
    And I press "Save"
    Then I should see "hmustermann has been created"
    And 1 email should have been sent
    When I log out
    Then I should see "Welcome"
    When I am logged in as "hmustermann"
    Then I should see "hmustermann"
