Feature: Isolated entities
  
  @javascript
  Scenario: show isolated entities
    Given the entity "Mona Lisa" of kind "work/works"
    And the entity "Leonardo" of kind "person/people"
    And the entity "Le Louvre" of kind "institution/institutions"
    And the relationship "Leonardo" "has created" "Mona Lisa"
    And I am logged in as "admin"
    When I follow "Isolated entities"
    Then I should see "Le Louvre"
    And I should not see "Mona Lisa"
    And I should not see "Leonardo"
