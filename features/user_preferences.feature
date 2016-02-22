Feature: Manage user preferences
  In order to access features more easily
  Users should be able to
  manage their preferences

  @javascript
  Scenario: Set the home page to the gallery
    Given I am logged in as "admin"
    When follow "Edit profile"
    And I select "New entries" from "user[home_page]"
    And I press "Save"
    Then I should be on the home page
    When I re-login as "admin"
    Then I should be on the gallery
  
    
  Scenario: Set the home page to the expert search
    Given I am logged in as "admin"
    When follow "Edit profile"
    And I select "Expert search" from "user[home_page]"
    And I press "Save"
    Then I should be on the home page
    
    When I go to the logout page
    And I fill in "username" with "admin"
    And I fill in "password" with "admin"
    And I press "Login"
    Then I should be on the expert search
    
    
  Scenario: Set the home page to the gallery but request the expert search
    Given I am logged in as "admin"
    When follow "Edit profile"
    And I select "New entries" from "user[home_page]"
    And I press "Save"
    Then I should be on the home page
    
    When I go to the logout page
    And I go to the expert search
    Then I should be on the login page
    When I fill in "username" with "admin"
    And I fill in "password" with "admin"
    And I press "Login"
    Then I should be on the expert search
    