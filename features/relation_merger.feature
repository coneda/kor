Feature: Relation merger

  @javascript @noseed
  Scenario: try merging unmatching relations, then invert one and merge again
    Given the default test data
    And I am logged in as "admin"
    When I follow "Administration"
    And I follow "Relations"
    Then I should see "has created / has been created by"

    When I follow "create relation"
    And I fill in "Name" with "has been created by"
    And I fill in "Inversion" with "has created"
    And I select "person" from "Permitted type (to)"
    And I select "Werk" from "Permitted type (from)"
    And I press "Save"
    Then I should see "has been created by / has created"

    When I follow "merge"
    Then I should see "Add relations to this merge"
    When I follow "add to merge" within "[data-is=kor-relations] tbody tr:nth-child(1)"
    And I follow "add to merge" within "[data-is=kor-relations] tbody tr:nth-child(2)"

    # try removing it from the list again
    And I follow "remove" within "kor-relation-merger li:last-child"
    Then I should see "Add relations to this merge"

    When I follow "add to merge" within "[data-is=kor-relations] tbody tr:nth-child(1)"
    And I follow "has created / has been created by" within "kor-relation-merger"
    And I press "check"

    Then I should see "you can only merge relations with matching endpoints"
    And I ignore the next confirmation box
    When I follow "invert" within "[data-is=kor-relations] tbody tr:nth-child(1)"
    Then I should not see "has been created by / has created" within "[data-is=kor-relations] tbody"
    And I should not see "has created" within "kor-relation-merger"

    When I follow "add to merge" within "[data-is=kor-relations] tbody tr:nth-child(1)"
    When I follow "add to merge" within "[data-is=kor-relations] tbody tr:nth-child(2)"
    And I follow "has created / has been created by" within "kor-relation-merger li:first-child"
    And I press "merge"
    Then I should see "merged successfully"

    Then there should only be one relation "has created / has been created by"
