Feature: Welcome
  As a user
  In order to get a first impression of KOR
  I want to see a welcome page
  
  
  Background:
    Given I am logged in as "admin"
    And Leonardo, Mona Lisa and a medium as correctly related entities
    And the user "guest"
    And I am logged out
  
  
  @javascript
  Scenario: Welcome page as guest
    Given I am on the welcome page
    Then I should see "Welcome"
    And I should see "This is a testing installation"
    And I should not see "Randomly selected entries"
    And I should not see "Mona Lisa"
    And I should not see "Leonardo"
    
    
  @javascript
  Scenario: Welcome as a logged in user
    Given I am logged in as "admin"
    And I am on the welcome page
    Then I should see "Welcome"
    And I should see "This is a testing installation"
    And I should see "Randomly selected entries"
    And I should see "Mona Lisa"
    And I should see "Leonardo"


  @javascript
  Scenario: Show the 'report a problem' link to admins
    Given I am logged in as "admin"
    And I am on the welcome page
    Then I should see a link "Report a problem" leading to "github.com"


  @javascript
  Scenario: Show the 'report a problem' link to non-admins
    Given I am logged in as "jdoe"
    And I am on the welcome page
    Then I should see a link "Report a problem" leading to "admin@example.com"


  @javascript
  Scenario: Don't show the clipboard to guests
    And the entity "Mona Lisa" of kind "Werk/Werke"
    And user "guest" is allowed to "view" collection "default" via credential "guests"
    When I go to the welcome page
    Then I should not see "Clipboard" within "#menu"
    And I should not see "Session"
    When I go to the entity page for "Mona Lisa"
    Then I should not see "Clipboard"
    And I should not see "Session" within "#session_info"
    And I should not see link "Target"

