Feature: Authentication and Authorization

  Scenario: show the login page unless there is a guest account
  Scenario: with a guest account, without authentication, show the expert search
  Scenario: with no guest account, when authenticated, show the expert search  
  
  Scenario: Reset password with wrong email address
    When I go to the login page
    And I follow "Forgot your password?"
    And I fill in "Please enter your email address" with "does@not.exist"
    And I press "Reset"
    Then I should see "could not be found"

  Scenario: Reset password with correct email address
    Given the user "jdoe"
    When I go to the login page
    And I follow "Forgot your password?"
    And I fill in "Please enter your email address" with "jdoe@coneda.net"
    And I press "Reset"
    Then I should see "A new password has been created and sent to the entered email address"
    
  Scenario: Reset admin password
    When I go to the login page
    And I follow "Forgot your password?"
    And I fill in "Please enter your email address" with "admin@example.com"
    And I press "Reset"
    Then I should see "please contact your hosting team"

  Scenario: Login after a session timeout
    Given I am logged in as "admin"
    And the session has expired
    And I reload the page
    When I go to the entity page for "Mona Lisa"
    Then I should not see "Mona Lisa"
    And I should see "Access denied"
    Given the session is not forcibly expired anymore
    And I reload the page
    When I follow "login" within "[data-is=kor-access-denied]"
    When I fill in "Username" with "admin"
    And I fill in "Password" with "admin"
    And I press "Login"
    And I should see "Mona Lisa"
    Then I should be on the entity page for "Mona Lisa"

  Scenario: Show only global groups when not logged in
    And I am on the root page
    Then I should see "Global groups"
    And I should not see "Personal groups"
    And I should not see "Shared groups"
    And I should not see "Published groups"

  Scenario: I should 'returned to' my original location after successful login
    Given I go to the config page
    Then I should see "Unfortunately you do not have the required rights"
    And I should see "Access denied" within ".w-content"
    When I follow "login" within ".w-content"
    When I fill in "Username" with "admin"
    And I fill in "Password" with "admin"
    And I press "Login"
    Then I should see "Settings"
