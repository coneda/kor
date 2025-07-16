Feature: Authentication and Authorization

  # Scenario: show the login page unless there is a guest account
  # Scenario: with a guest account, without authentication, show the expert search
  # Scenario: with no guest account, when authenticated, show the expert search

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
    Then I should see "logged in as: guest"
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

  Scenario: Show only global collections when not logged in
    And I am on the root page
    Then I should see "Global collections"
    And I should not see "Personal collections"
    And I should not see "Shared collections"
    And I should not see "Published collections"

  Scenario: I should 'returned to' my original location after successful login
    Given I go to the config page
    Then I should see "Unfortunately you do not have the required rights"
    And I should see "Access denied" within ".w-content"
    When I follow "login" within ".w-content"
    When I fill in "Username" with "admin"
    And I fill in "Password" with "admin"
    And I press "Login"
    Then I should see "Settings"

 Scenario: Try accessing the app without accepted terms
   Given user "jdoe" didn't accept the terms
   And I am logged in as "jdoe"
   Then I should see "You have to accept our terms of use"
   And I should see "enter a legal notice here"
   When I press "Accept terms"
   Then I should see "You have accepted the terms of use"
   When I go to the search page
   Then I should see "Search" within ".w-content"

 Scenario: Login with env auth and use 'forgot password'
   Given the user "hmustermann"
   And the user "ldap"
   When I am on the login page
   And I fill in "Username" with "hmustermann"
   And I fill in "Password" with "123456"
   And I press "Login"
   Then I should see "you have been logged in"
   And I should see "logged in as: Hans Mustermann"
   When I follow "Edit profile"
   Then I should see "Hans Mustermann"
   Then I should not see "Repeat password"
   And I should see a link "change your password with them" leading to "https://idp.example.com/change_password"
