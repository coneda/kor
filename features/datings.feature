Feature: datings
  Scenario: create an entity with a dating
    Given I am logged in as "admin"
    When I go to the new "work-Entity" page
    And I fill in "name" with "Der Schrei"
    And I press "Add" within widget "kor-datings-editor"
    And I fill in "Type of dating" with "created in"
    And I fill in "Dating" with "1766"
    And I press "Save"
    Then I should be on the entity page for "Der Schrei"
    And I should see "created in: 1766"

  Scenario: create an entity with two datings
    Given I am logged in as "admin"
    When I go to the new "work-Entity" page
    And I fill in "name" with "Der Schrei"
    And I press "Add" within widget "kor-datings-editor"
    And I fill in "Type of dating" with "created in"
    And I fill in "Dating" with "1503"
    And I press "Add" within widget "kor-datings-editor"
    And I fill in "Type of dating" with "revised in" within "kor-datings-editor li:nth-child(2)"
    And I fill in "Dating" with "1506" within "kor-datings-editor li:nth-child(2)"
    And I press "Save"
    Then I should be on the entity page for "Der Schrei"
    And I should see "created in: 1503"
    And I should see "revised in: 1506"

  Scenario: show an existing dating while editing
    Given I am logged in as "admin"
    And entity "Mona Lisa" has dating "created in: 1503"
    When I go to the entity page for "Mona Lisa"
    And I follow "edit"
    Then I should see the prefilled dating "created in: 1503"

  Scenario: add a first dating to an existing entity
    Given I am logged in as "admin"
    When I go to the entity page for "Mona Lisa"
    And I follow "edit"
    When I scroll down
    And I press "Add"
    And I fill in "Type of dating" with "created in"
    And I fill in "Dating" with "1503"
    And I press "Save"
    Then I should be on the entity page for "Mona Lisa"
    And I should see "created in: 1503"

  Scenario: add a second dating to an existing entity
    Given I am logged in as "admin"
    And entity "Mona Lisa" has dating "created in: 1503"
    When I go to the entity page for "Mona Lisa"
    And I follow "edit"
    When I scroll down
    And I press "Add"
    And I fill in "Type of dating" with "revised in" within "kor-datings-editor li:nth-child(2)"
    And I fill in "Dating" with "1506" within "kor-datings-editor li:nth-child(2)"
    And I press "Save"
    Then I should be on the entity page for "Mona Lisa"
    And I should see "created in: 1503"
    And I should see "revised in: 1506"

  Scenario: remove a dating from an entity
    Given I am logged in as "admin"
    And entity "Mona Lisa" has dating "created in: 1503"
    And entity "Mona Lisa" has dating "destroyed in: 2017"
    When I go to the entity page for "Mona Lisa"
    And I follow "edit"
    And I press "delete" within "kor-datings-editor li:nth-child(2)"
    And I press "Save"
    Then I should be on the entity page for "Mona Lisa"
    And I should see "created in: 1503"
    And I should not see "revised in: 2017"

  Scenario: remove all datings from an entity
    Given I am logged in as "admin"
    And entity "Mona Lisa" has dating "created in: 1503"
    And entity "Mona Lisa" has dating "destroyed in: 2017"
    When I go to the entity page for "Mona Lisa"
    And I follow "edit"
    And I press "delete" within "kor-datings-editor li:last-child"
    And I press "delete" within "kor-datings-editor"
    And I press "Save"
    Then I should be on the entity page for "Mona Lisa"
    And I should not see "created in: 1503"
    And I should not see "revised in: 2017"

  Scenario: modify one of two datings
    Given I am logged in as "admin"
    Given the entity "Mona Lisa" of kind "work/works"
    And entity "Mona Lisa" has dating "created in: 1503"
    And entity "Mona Lisa" has dating "destroyed in: 2017"
    When I go to the entity page for "Mona Lisa"
    And I follow "edit"
    And I fill in "Type of dating" with "revised in" within "kor-datings-editor li:nth-child(2)"
    And I fill in "Dating" with "1508" within "kor-datings-editor li:nth-child(2)"
    And I press "Save"
    Then I should be on the entity page for "Mona Lisa"
    And I should see "created in: 1503"
    And I should see "revised in: 1508"
