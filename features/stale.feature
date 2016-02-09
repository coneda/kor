Feature: Stale update protection
  As an editor
  In order not to overwrite changes made by others
  I want to receive errors on stale updates
  

  @javascript  
  Scenario: Update a stale entity
    Given I am logged in as "admin"
    And the entity "Mona Lisa" of kind "Werk/Werke"
    When I go to the edit page for "entity" "Mona Lisa"
    And the "entity" "Mona Lisa" is updated behind the scenes
    And I press "Save"
    Then I should see "The entity has been edited meanwhile. Please find the new values below"
  
  
  Scenario: Update a stale user
    Given I am logged in as "admin"
    And the user "joe"
    When I go to the edit page for "user" "joe"
    And the "user" "joe" is updated behind the scenes
    And I press "Save"
    Then I should see "The user has been edited meanwhile. Please find the new values below"
    
    
  Scenario: Update a stale relation
    Given I am logged in as "admin"
    And the relation "wurde geschaffen von/hat geschaffen"
    When I go to the edit page for "relation" "wurde geschaffen von/hat geschaffen"
    And the "relation" "wurde geschaffen von/hat geschaffen" is updated behind the scenes
    And I press "Save"
    Then I should see "The relation has been edited meanwhile. Please find the new values below"
    
