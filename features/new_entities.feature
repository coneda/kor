Feature: New entities
  As a user
  In order to see what is new
  I want to have a page listing new entities


  @javascript
  Scenario: List new entities
    Given I am logged in as "admin"
    And the entity "Mona Lisa" of kind "Work/Works"
    When I follow "Neue Entitäten"
    Then I should see "Mona Lisa"
    When I follow "Mona Lisa"
    Then I should be on the entity page for "Mona Lisa"