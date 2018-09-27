Feature: Collection selector
  As a user
  In order to see what entities are available to others
  I want to search within specific collections
  
  
  Background:
    Given the entity "Mona Lisa" of kind "Werk/Werke" inside collection "Default"
    And the entity "Der Schrei" of kind "Werk/Werke" inside collection "Project"
  

  @javascript
  Scenario: One collection available
    Given I destroy collection "Project"
    And I am logged in as "admin"
    And I am on the search page
    Then I should not see "Collections: all"
    When I fill in "Name" with "Mona Lisa"
    And I press "Search"
    Then I should see "Mona Lisa" within "kor-search-result"

  
  @javascript
  Scenario: Three collections available
    Given user "admin" is allowed to "view" collection "Project" through credential "admins"
    And I am logged in as "admin"
    When I am on the search page
    Then I should see /Collections/ within ".layout_panel.left form"
    And I should see /Default, Project/ within ".layout_panel.left form"
    When I press "Search"
    Then I should see "Mona Lisa" within ".entity_list"
    And I should see "Der Schrei" within ".entity_list"
    
    
  @javascript
  Scenario: Search only one collection
    Given user "admin" is allowed to "view" collection "Project" through credential "admins"
    And I am logged in as "admin"
    When I am on the search page
    And I select "Project" from the collections selector
    And I press "Search"
    Then I should see "Der Schrei" within ".search_result"
    And I should not see "Mona Lisa"
