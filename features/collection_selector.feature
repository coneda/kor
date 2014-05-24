Feature: Collection selector
  As a user
  In order to see what entities are available to others
  I want to search within specific collections
  
  
  Background:
    Given the entity "Mona Lisa" of kind "Werk/Werke" inside collection "Default"
    And the entity "Der Schrei" of kind "Werk/Werke" inside collection "Project"
  

  @javascript
  Scenario: One collection available
    Given I am logged in as "admin"
    And I am on the expert search page
    Then I should not see "Sammlungen" within ".layout_panel.left form"
    When I fill in "query[name]" with "Mona Lisa"
    And I press "Suchen"
    Then I should see "Mona Lisa" within ".search_result"

  
  @javascript
  Scenario: Three collections available
    Given user "admin" is allowed to "view" collection "Project" through credential "admins"
    And I am logged in as "admin"
    When I am on the expert search page
    Then I should see /Sammlungen/ within ".layout_panel.left form"
    And I should see /Default, Project/ within ".layout_panel.left form"
    When I press "Suchen"
    Then I should see "Mona Lisa" within ".entity_list"
    And I should see "Der Schrei" within ".entity_list"
    
    
  @javascript
  Scenario: Search only one collection
    Given user "admin" is allowed to "view" collection "Project" through credential "admins"
    And I am logged in as "admin"
    When I am on the expert search page
    And I select "Project" from the collections selector
    And I press "Suchen"
    Then I should see "Der Schrei" within ".search_result"
    And I should not see "Mona Lisa"
