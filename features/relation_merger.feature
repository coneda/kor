Feature: Relation merger
  Scenario: try merging unmatching relations, then invert one and merge again
    And I am logged in as "admin"
    And I follow "Relations"
    Then I should see "has created / has been created by"

    When I follow "add"
    And I fill in "Name" with "has been created by"
    And I fill in "Inversion" with "has created"
    And I select "person" from "Permitted type (to)"
    And I select "work" from "Permitted type (from)"
    And I press "Save"
    Then I should see "has been created by / has created"

    When I follow "merge"
    Then I should see "Add relations to this merge"
    When I follow "add to merge" within the row for relation "has been created by / has created"
    And I follow "add to merge" within the row for relation "has created / has been created by"

    # try removing it from the list again
    And I follow "remove" within relation merger row for relation "has been created by / has created"
    Then I should see "Add relations to this merge"

    When I follow "add to merge" within the row for relation "has been created by / has created"
    And I follow "has created / has been created by" within "kor-relation-merger"
    And I press "check"

    Then I should see "you can only merge relations with matching endpoints"
    And I ignore the next confirmation box
    When I follow "invert" within the row for relation "has been created by / has created"
    Then I should not see "has been created by / has created" within "[data-is=kor-relations] tbody"
    And I should not see "has created" within "kor-relation-merger"

    When I follow "add to merge" within "[data-is=kor-relations] tbody tr:nth-child(1)"
    When I follow "add to merge" within "[data-is=kor-relations] tbody tr:nth-child(2)"
    And I follow "has created / has been created by" within "kor-relation-merger li:first-child"
    And I press "merge"
    Then I should see "merged successfully"

    Then there should only be one relation "has created / has been created by"
