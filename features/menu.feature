Feature: Navigation Menu

  @javascript
  Scenario: User Menu
    Given I am logged in as "john"
    And "Groups" is expanded
    Then I should see "Simple search" within "#menu"
    And I should see "Expert search" within "#menu"
    And I should see "New entries" within "#menu"
    And I should see "Clipboard" within "#menu"
    And I should see "Groups" within "#menu"
    And I should see "Global" within "#menu"
    And I should see "Personal" within "#menu"
    And I should see "Shared" within "#menu"
    And I should see "Published" within "#menu"
    And I should see "Edit profile" within "#menu"
    And I should see "Statistics" within "#menu"
    And I should not see "Administration" within "#menu"
    And I should not see option "Create entity" within "#menu"
    And I should not see "Invalid entities" within "#menu"
    And I should not see "New entities" within "#menu"
    

  @javascript
  Scenario: Admin Menu
    Given I am logged in as "admin"
    And "Groups" is expanded
    And "Administration" is expanded
    Then I should see "Simple search" within "#menu"
    And I should see "Expert search" within "#menu"
    And I should see "New entries" within "#menu"
    And I should see "Clipboard" within "#menu"
    And I should see "Groups" within "#menu"
    And I should see "Global" within "#menu"
    And I should see "Personal" within "#menu"
    And I should see "Shared" within "#menu"
    And I should see "Published" within "#menu"
    And I should see "Edit profile" within "#menu"
    And I should see "Statistics" within "#menu"
    And I should see "Administration" within "#menu"
    And I should see option "Create entity" within "#menu"
    And I should see "Invalid entities" within "#menu"
    And I should see "New entities" within "#menu"
    And I should see "General" within "#menu"
    And I should see "Relations" within "#menu"
    And I should see "Entity types" within "#menu"
    And I should see "Collections" within "#menu"
    And I should see "User groups" within "#menu"
    And I should see "User administration" within "#menu"

    
  @javascript
  Scenario: User menu as a user_admin but not credential_admin
    Given the user "john" is a "user_admin"
    And I am logged in as "john"
    And "Administration" is expanded
    Then I should see "User administration" within "#menu"
    And I should not see "User groups" within "#menu"
    
  
  @javascript
  Scenario: Toggle groups menu as a admin
    Given I am logged in as "admin"
    When I go to the home page
    And I follow "Groups"
    Then I should really see element "#group_links"
    When I follow "Groups"
    Then I should not really see element "#group_links"
    
    
  @javascript
  Scenario: No admin rights => no config menu
    Given the user "john"
    And I am logged in as "john"
    When I go to the root page
    Then I should not see "Administration"
    