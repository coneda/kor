Feature: Invalid entities
  Scenario: Paginate invalid entities
    Given I am logged in as "admin"
    And 31 invalid entities "Entity" of kind "Werk/Werke" inside collection "default"
    And I go to the invalid entities page
    Then I should see "Entity_0"
    And I should see "Entity_19"
    When I follow "next" within "kor-pagination.top"
    And I should not see "Entity_19"
    Then I should see "Entity_20"
    And I should see "Entity_30"
