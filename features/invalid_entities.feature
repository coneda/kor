Feature: Invalid entities
  In order to correct migration errors
  As an admin
  I want to access a list of invalid entities


  @javascript
  Scenario: Paginate invalid entities
    Given I am logged in as "admin"
    And 31 invalid entities "Entity" of kind "Werk/Werke" inside collection "default"
    And I go to the invalid entities page
    Then I should see "Entity_0"
    And I should see "Entity_29"
    When I follow "Pager right"
    Then I should not see "Entity_29"
    And I should see "Entity_30"