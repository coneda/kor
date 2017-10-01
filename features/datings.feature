@javascript
Feature: datings

  Background:
    Given the kind "work/works"
    And I am logged in as "admin"

  Scenario: create an entity with a dating
    When I go to the new "work-Entity" page
    And I fill in "entity[name]" with "Mona Lisa"
    And I click element "[data-name=plus]" within "#datings"
    And I fill in "[name*=label]" with "created in" within "#datings"
    And I fill in "[name*=dating_string]" with "1503" within "#datings"
    And I press "Create"
    Then entity "Mona Lisa" should have dating "created in: 1503"

  Scenario: create an entity with two datings
    When I go to the new "work-Entity" page
    And I fill in "entity[name]" with "Mona Lisa"
    And I click element "[data-name=plus]" within "#datings"
    And I fill in "[name*=label]" with "created in" within "#datings"
    And I fill in "[name*=dating_string]" with "1503" within "#datings"
    And I click element "[data-name=plus]" within "#datings"
    And I fill in "[name*=label]" with "revised in" within "#datings .ats .attachment:nth-child(2)"
    And I fill in "[name*=dating_string]" with "1506" within "#datings .ats .attachment:nth-child(2)"
    And I press "Create"
    Then entity "Mona Lisa" should have dating "created in: 1503"
    And entity "Mona Lisa" should have dating "revised in: 1506"

  Scenario: show an existing dating while editing
    Given the entity "Mona Lisa" of kind "work/works"
    And entity "Mona Lisa" has dating "created in: 1503"
    When I go to the edit page for "entity" "Mona Lisa"
    Then I should see the prefilled dating "created in: 1503"

  Scenario: add a first dating to an existing entity
    Given the entity "Mona Lisa" of kind "work/works"
    When I go to the edit page for "entity" "Mona Lisa"
    And I click element "[data-name=plus]" within "#datings"
    And I fill in "[name*=label]" with "created in" within "#datings"
    And I fill in "[name*=dating_string]" with "1503" within "#datings"
    And I press "Save"
    Then entity "Mona Lisa" should have dating "created in: 1503"

  Scenario: add a second dating to an existing entity
    Given the entity "Mona Lisa" of kind "work/works"
    And entity "Mona Lisa" has dating "created in: 1503"
    When I go to the edit page for "entity" "Mona Lisa"
    And I click element "[data-name=plus]" within "#datings"
    And I fill in "[name*=label]" with "revised in" within "#datings .ats .attachment:nth-child(2)"
    And I fill in "[name*=dating_string]" with "1506" within "#datings .ats .attachment:nth-child(2)"
    And I press "Save"
    Then entity "Mona Lisa" should have dating "created in: 1503"
    And entity "Mona Lisa" should have dating "revised in: 1506"

  Scenario: remove a dating from an entity
    Given the entity "Mona Lisa" of kind "work/works"
    And entity "Mona Lisa" has dating "created in: 1503"
    And entity "Mona Lisa" has dating "destroyed in: 2017"
    When I go to the edit page for "entity" "Mona Lisa"
    And I click element "[data-name=minus]" within "#datings .ats .attachment:nth-child(2)"
    And I press "Save"
    Then entity "Mona Lisa" should have dating "created in: 1503"
    And entity "Mona Lisa" should not have dating "revised in: 1506"

  Scenario: remove all datings from an entity
    Given the entity "Mona Lisa" of kind "work/works"
    And entity "Mona Lisa" has dating "created in: 1503"
    And entity "Mona Lisa" has dating "destroyed in: 2017"
    When I go to the edit page for "entity" "Mona Lisa"
    And I click element "[data-name=minus]" within "#datings .ats .attachment:nth-child(2)"
    And I click element "[data-name=minus]" within "#datings .ats .attachment:nth-child(1)"
    And I press "Save"
    Then entity "Mona Lisa" should not have dating "created in: 1503"
    And entity "Mona Lisa" should not have dating "revised in: 1506"

  Scenario: modify one of two datings
    Given the entity "Mona Lisa" of kind "work/works"
    And entity "Mona Lisa" has dating "created in: 1503"
    And entity "Mona Lisa" has dating "destroyed in: 2017"
    When I go to the edit page for "entity" "Mona Lisa"
    And I fill in "[name*=label]" with "revised in" within "#datings .ats .attachment:nth-child(2)"
    And I fill in "[name*=dating_string]" with "1508" within "#datings .ats .attachment:nth-child(2)"
    And I press "Save"
    Then entity "Mona Lisa" should have dating "created in: 1503"
    And entity "Mona Lisa" should have dating "revised in: 1508"
