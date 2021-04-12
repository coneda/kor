Feature: Isolated entities
  Scenario: show isolated entities
    And the entity "Van Gogh" of kind "person/people"
    And I am logged in as "admin"
    When I follow "Isolated entities"
    Then I should see "Van Gogh"
    And I should not see "Mona Lisa"
    And I should not see "Leonardo"
    And I should not see "Louvre"
    And I should not see "Paris"
