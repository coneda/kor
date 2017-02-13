Feature: Guest account
  As an unregistered visitor
  In order to see any entities
  I want to use a guest account
  

  @javascript  
  Scenario: View the system as guest
    Given user "guest" is allowed to "view" collection "Default" through credential "guests"
    When I go to the gallery page
    Then I should not be on the login page
  

  @javascript  
  Scenario: See a login button when not logged in
    Given user "guest" is allowed to "view" collection "Default" through credential "guests"
    When I go to the expert search page
    Then I should see element "a[href='/login']" within "kor-menu"
    And I should not see "Profil bearbeiten"
    
    
  @javascript
  Scenario: View the profile page as guest
    Given user "guest" is allowed to "view" collection "Default" through credential "guests"
    When I go to the profile page for user "guest"
    Then I should see "Access denied"


  @javascript
  Scenario: Don't show tags field when no tags have been entered
    Given user "guest" is allowed to "view" collection "Default" through credential "guests"
    And the entity "Mona Lisa" of kind "Work/Works"
    And I go to the entity page for "Mona Lisa"
    Then I should not see "Tags"