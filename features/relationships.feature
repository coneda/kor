Feature: relate entities using predefined relations
  In order to maximize normalization
  As a editor
  I want to relate entities


  @javascript
  Scenario: create relationship
    Given I am logged in as "admin"
    And the setup "Bamberg"
    And I mark "Sankt Stephan" as current entity
    When I go to the entity page for "Bamberger Apokalypse"
    And I follow "Plus" within ".relationships"
    Then I should see "Bamberger Apokalypse" within ".canvas"
    And I should see "Sankt Stephan" within ".canvas"
    When I select "befindet sich in" from "relationship[relation_name]"
    And I press "Erstellen"
    Then I should be on the entity page for "Bamberger Apokalypse"
    And I should see "Verknüpfung wurde angelegt"
    And I should see "befindet sich in" within ".canvas"
    And I should see "Sankt Stephan" within ".canvas"


  @javascript
  Scenario: edit relationship
    Given I am logged in as "admin"
    And the triple "Werk/Werke" "Bamberger Apokalypse" "befindet sich in/Aubewahrungsort von" "Institution/Institutionen" "Sankt Stephan"
    When I go to the entity page for "Bamberger Apokalypse"
    And I follow "Pen" within ".relationship.stage_panel"
    And I follow "Plus" within "#properties"
    And I fill in "relationship[properties][]" with "Bibliothek"
    And I press "Speichern"
    Then I should be on the entity page for "Bamberger Apokalypse"
    And I should see "Verknüpfung wurde abgeändert"
    Then I should see "Bibliothek" within ".relationship .properties"


  @javascript
  Scenario: delete relationship
    Given I am logged in as "admin"
    And the triple "Werk/Werke" "Bamberger Apokalypse" "befindet sich in/Aubewahrungsort von" "Institution/Institutionen" "Sankt Stephan"
    When I go to the entity page for "Bamberger Apokalypse"
    And I follow the delete link within ".relationships"
    Then I should not see "befindet sich in" within ".relationships"
    And I should not see "Sankt Stephan" within ".relationships"
    

  @javascript    
  Scenario: show info when no relations available for given kinds
    Given I am logged in as "admin"
    And Leonardo, Mona Lisa and a medium as correctly related entities
    When I mark "Leonardo da Vinci" as current entity
    And I go to the new relationship page for "Leonardo da Vinci"
    Then I should see "Für diese Kombination ist keine Relation vorgesehen"
    
    
  @javascript
  Scenario: relate to an entity for which I only have view rights
    Given I am logged in as "admin"
    And user "admin" is allowed to "view" collection "viewable" through credential "viewers"
    And user "admin" is allowed to "edit/view" collection "editable" through credential "editors"
    And the entity "Mona Lisa" of kind "Werk/Werke" inside collection "editable"
    And the entity "Leonardo da Vinci" of kind "Person/Personen" inside collection "viewable"
    And the relation "wurde geschaffen von/hat geschaffen" between "Werk/Werke" and "Person/Personen"
    When all entities of kind "Werk/Werke" are in the clipboard
    And I mark "Leonardo da Vinci" as current entity
    And I go to the clipboard page
    And I select "verknüpfen mit" from "clipboard_action"
    And I wait for "2" seconds
    And I press "Senden"
    Then I should be on the entity page for "Leonardo da Vinci"
    
    

