Feature: Guest account
  Scenario: View the system as guest
    When I go to the gallery page
    Then I should not be on the login page

  Scenario: See a login button when not logged in
    When I go to the search page
    Then I should see link "Login"
    And I should not see "Profil bearbeiten"
    
  Scenario: View the profile page as guest
    When I go to the profile page
    Then I should see "Access denied"

  Scenario: Don't show tags field when no tags have been entered
    And I go to the entity page for "Mona Lisa"
    Then I should not see "Tags"