Feature: Stale update protection
  Scenario: Update a stale entity
    Given I am logged in as "admin"
    And the entity "Mona Lisa" of kind "Werk/Werke"
    When I go to the edit page for "entity" "Mona Lisa"
    And I should see "Edit entity"
    And I wait for "0.5" seconds
    And the "entity" "Mona Lisa" is updated behind the scenes
    And I press "Save"
    Then I should see "has been updated in the meantime"
  
  Scenario: Update a stale user
    Given I am logged in as "admin"
    And the user "joe"
    When I go to the edit page for "user" "joe"
    Then I should see "Edit user"
    And I wait for "0.5" seconds
    And the "user" "joe" is updated behind the scenes
    And I press "Save"
    Then I should see "has been updated in the meantime"
  
  Scenario: Update a stale relation
    Given I am logged in as "admin"
    When I go to the edit page for "relation" "has created"
    Then I should see "Edit relation"
    And I wait for "0.5" seconds
    When the "relation" "has created" is updated behind the scenes
    And I press "Save"
    Then I should see "has been updated in the meantime"
    