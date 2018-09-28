@javascript
Feature: datings

  Background:
    Given the kind "work/works"
    And I am logged in as "admin"

  @javascript
  Scenario: create an entity with a dating
    When I go to the new "work-Entity" page
    And I fill in "name" with "Mona Lisa"
    And I press "Add" within widget "kor-datings-editor"
    And I fill in "Type of dating" with "created in"
    And I fill in "Dating" with "1503"
    And I press "Save"
    Then entity "Mona Lisa" should have dating "created in: 1503"

  @javascript
  Scenario: create an entity with two datings
    When I go to the new "work-Entity" page
    And I fill in "name" with "Mona Lisa"
    And I press "Add" within widget "kor-datings-editor"
    And I fill in "Type of dating" with "created in"
    And I fill in "Dating" with "1503"
    And I press "Add" within widget "kor-datings-editor"
    And I fill in "Type of dating" with "revised in" within "kor-datings-editor li:nth-child(2)"
    And I fill in "Dating" with "1506" within "kor-datings-editor li:nth-child(2)"
    And I press "Save"
    Then entity "Mona Lisa" should have dating "created in: 1503"
    And entity "Mona Lisa" should have dating "revised in: 1506"

  @javascript
  Scenario: show an existing dating while editing
    Given the entity "Mona Lisa" of kind "work/works"
    And entity "Mona Lisa" has dating "created in: 1503"
    When I go to the entity page for "Mona Lisa"
    And I follow "edit"
    Then I should see the prefilled dating "created in: 1503"

  @javascript
  Scenario: add a first dating to an existing entity
    Given the entity "Mona Lisa" of kind "work/works"
    When I go to the entity page for "Mona Lisa"
    And I follow "edit"
    When I scroll down
    And I press "Add"
    And I fill in "Type of dating" with "created in"
    And I fill in "Dating" with "1503"
    And I press "Save"
    Then entity "Mona Lisa" should have dating "created in: 1503"

  @javascript
  Scenario: add a second dating to an existing entity
    Given the entity "Mona Lisa" of kind "work/works"
    And entity "Mona Lisa" has dating "created in: 1503"
    When I go to the entity page for "Mona Lisa"
    And I follow "edit"
    When I scroll down
    And I press "Add"
    And I fill in "Type of dating" with "revised in" within "kor-datings-editor li:nth-child(2)"
    And I fill in "Dating" with "1506" within "kor-datings-editor li:nth-child(2)"
    And I press "Save"
    Then entity "Mona Lisa" should have dating "created in: 1503"
    And entity "Mona Lisa" should have dating "revised in: 1506"

  @javascript
  Scenario: remove a dating from an entity
    Given the entity "Mona Lisa" of kind "work/works"
    And entity "Mona Lisa" has dating "created in: 1503"
    And entity "Mona Lisa" has dating "destroyed in: 2017"
    When I go to the entity page for "Mona Lisa"
    And I follow "edit"
    And I press "delete" within "kor-datings-editor li:nth-child(2)"
    And I press "Save"
    Then entity "Mona Lisa" should have dating "created in: 1503"
    And entity "Mona Lisa" should not have dating "revised in: 1506"

  @javascript
  Scenario: remove all datings from an entity
    Given the entity "Mona Lisa" of kind "work/works"
    And entity "Mona Lisa" has dating "created in: 1503"
    And entity "Mona Lisa" has dating "destroyed in: 2017"
    When I go to the entity page for "Mona Lisa"
    And I follow "edit"
    And I press "delete" within "kor-datings-editor li:last-child"
    And I press "delete" within "kor-datings-editor"
    And I press "Save"
    Then entity "Mona Lisa" should not have dating "created in: 1503"
    And entity "Mona Lisa" should not have dating "revised in: 1506"

  @javascript
  Scenario: modify one of two datings
    Given the entity "Mona Lisa" of kind "work/works"
    And entity "Mona Lisa" has dating "created in: 1503"
    And entity "Mona Lisa" has dating "destroyed in: 2017"
    When I go to the entity page for "Mona Lisa"
    And I follow "edit"
    And I fill in "Type of dating" with "revised in" within "kor-datings-editor li:nth-child(2)"
    And I fill in "Dating" with "1508" within "kor-datings-editor li:nth-child(2)"
    And I press "Save"
    Then entity "Mona Lisa" should have dating "created in: 1503"
    And entity "Mona Lisa" should have dating "revised in: 1508"
