Feature: Navigation Menu

  @javascript
  Scenario: User Menu
    Given I am logged in as "john"
    And "Groups" is expanded
    Then I should see "Simple search" within "kor-menu"
    And I should see "Expert search" within "kor-menu"
    And I should see "New entries" within "kor-menu"
    And I should see "Clipboard" within "kor-menu"
    And I should see "Groups" within "kor-menu"
    And I should see "Global" within "kor-menu"
    And I should see "Personal" within "kor-menu"
    And I should see "Shared" within "kor-menu"
    And I should see "Published" within "kor-menu"
    And I should see "Edit profile" within "kor-menu"
    And I should see "Statistics" within "kor-menu"
    And I should not see "Administration" within "kor-menu"
    And I should not see option "Create entity" within "kor-menu"
    And I should not see "Invalid entities" within "kor-menu"
    And I should not see "New entities" within "kor-menu"
    

  @javascript
  Scenario: Admin Menu
    Given I am logged in as "admin"
    And "Groups" is expanded
    And "Administration" is expanded
    Then I should see "Simple search" within "kor-menu"
    And I should see "Expert search" within "kor-menu"
    And I should see "New entries" within "kor-menu"
    And I should see "Clipboard" within "kor-menu"
    And I should see "Groups" within "kor-menu"
    And I should see "Global" within "kor-menu"
    And I should see "Personal" within "kor-menu"
    And I should see "Shared" within "kor-menu"
    And I should see "Published" within "kor-menu"
    And I should see "Edit profile" within "kor-menu"
    And I should see "Statistics" within "kor-menu"
    And I should see "Administration" within "kor-menu"
    And I should see option "Create entity" within "kor-menu"
    And I should see "Invalid entities" within "kor-menu"
    And I should see "New entities" within "kor-menu"
    And I should see "General" within "kor-menu"
    And I should see "Relations" within "kor-menu"
    And I should see "Entity types" within "kor-menu"
    And I should see "Collections" within "kor-menu"
    And I should see "User groups" within "kor-menu"
    And I should see "User administration" within "kor-menu"

    
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
    