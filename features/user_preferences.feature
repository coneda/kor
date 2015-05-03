Feature: Manage user preferences
  In order to access features more easily
  Users should be able to
  manage their preferences

  @javascript
  Scenario: Set the home page to the gallery
    Given I am logged in as "admin"
    When follow "Profil bearbeiten"
    And I select "Neue Einträge" from "user[home_page]"
    And I press "Speichern"
    Then I should be on the home page
    
    When I go to the logout page
    And I fill in "username" with "admin"
    And I fill in "password" with "admin"
    And I press "Anmelden"
    Then I should be on the gallery
  
    
  Scenario: Set the home page to the expert search
    Given I am logged in as "admin"
    When follow "Profil bearbeiten"
    And I select "Expertensuche" from "user[home_page]"
    And I press "Speichern"
    Then I should be on the home page
    
    When I go to the logout page
    And I fill in "username" with "admin"
    And I fill in "password" with "admin"
    And I press "Anmelden"
    Then I should be on the expert search
    
    
  Scenario: Set the home page to the gallery but request the expert search
    Given I am logged in as "admin"
    When follow "Profil bearbeiten"
    And I select "Neue Einträge" from "user[home_page]"
    And I press "Speichern"
    Then I should be on the home page
    
    When I go to the logout page
    And I go to the expert search
    Then I should be on the login page
    When I fill in "username" with "admin"
    And I fill in "password" with "admin"
    And I press "Anmelden"
    Then I should be on the expert search
    
