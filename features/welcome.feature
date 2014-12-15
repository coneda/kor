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
    Then I should see "Willkommen"
    And I should see "Dies ist eine Testinstallation"
    And I should not see "Zufällig ausgewählte Einträge"
    And I should not see "Mona Lisa"
    And I should not see "Leonardo"
    
    
  @javascript
  Scenario: Welcome as a logged in user
    Given I am logged in as "admin"
    And I am on the welcome page
    Then I should see "Willkommen"
    And I should see "Dies ist eine Testinstallation"
    And I should see "Zufällig ausgewählte Einträge"
    And I should see "Mona Lisa"
    And I should see "Leonardo"


  @javascript
  Scenario: Show the 'report a problem' link to admins
    Given I am logged in as "admin"
    And I am on the welcome page
    Then I should see a link "Einen Fehler melden" leading to "github.com"


  @javascript
  Scenario: Show the 'report a problem' link to non-admins
    Given I am logged in as "jdoe"
    And I am on the welcome page
    Then I should see a link "Einen Fehler melden" leading to "admin@example.com"
