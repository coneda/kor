Feature: relations

  @javascript
  Scenario: create relation
    Given I am logged in as "admin"
    When I go to the relations page
    And I click icon "plus-square"
    And I fill in "Name" with "loves"
    And I fill in "Inversion" with "loves not"
    And I fill in "Description" with "love"
    And I ignore the next confirmation box
    And I press "Save"
    Then I should see "loves" within "[data-is=kor-relations]"
    And I should see "loves not" within "[data-is=kor-relations]"
    And I should see "love" within "[data-is=kor-relations]"

  @javascript
  Scenario: edit relation
    Given I am logged in as "admin"
    And the relation "loves/is being loved by" between "person/people" and "person/people"
    When I go to the relations page
    And I click icon "edit" within "[data-is=kor-relations]"
    And I fill in "Name" with "hates"
    And I fill in "Inversion" with "hates not"
    And I fill in "Description" with "hate"
    And I ignore the next confirmation box
    And I press "Save"
    Then I should see "hates" within "[data-is=kor-relations]"
    And I should see "hates not" within "[data-is=kor-relations]"
    And I should see "hate" within "[data-is=kor-relations]"
    And I should not see "loves" within "[data-is=kor-relations]"
    And I should not see "loves not" within "[data-is=kor-relations]"
    And I should not see "love" within "[data-is=kor-relations]"

  @javascript
  Scenario: delete relation
    Given I am logged in as "admin"
    And the relation "loves/is being loved by" between "person/people" and "person/people"
    When I go to the relations page
    And I ignore the next confirmation box
    And I click icon "remove" within "[data-is=kor-relations]"
    Then I should not see "loves"

  @javascript
  Scenario: Empty relation list
    Given I am logged in as "admin"
    And I go to the relations page
    Then I should not see "Reverse name"
    And I should see "No relations found"

  @javascript
  Scenario: make relation inherit from another
    Given I am logged in as "admin"
    And the relation "is ancestor of/is descendent of" between "person/people" and "person/people"
    When I go to the relations page
    And I click icon "plus-square"
    And I fill in "Name" with "is father of"
    And I fill in "Inversion" with "is son of"
    And I select "is ancestor of" from "Parent relation"
    And I select "person" from "Permitted type (from)"
    And I select "person" from "Permitted type (to)"
    And I press "Save"
    Then I should see "has been created"
    And relation "is father of" should have parent "is ancestor of"

  @javascript
  Scenario: resolve relation inheritance
    Given I am logged in as "admin"
    And the relation "is ancestor of/is descendent of" between "person/people" and "person/people"
    And the relation "is father of/is son of" inheriting from "is ancestor of"
    When I go to the relations page
    And I click icon "edit" within "[data-is=kor-relations] tbody tr:last-child"
    And I unselect "is ancestor of" from "Parent relation"
    And I select "person" from "Permitted type (from)"
    And I select "person" from "Permitted type (to)"
    And I press "Save"
    Then I should see "has been changed"
    And relation "is father of" should not have parent "is ancestor of"

  @javascript
  Scenario: make relation inherit from multiple anothers
    Given I am logged in as "admin"
    And the relation "is ancestor of/is descendent of" between "person/people" and "person/people"
    And the relation "is related to/is related to" between "person/people" and "person/people"
    When I go to the relations page
    And I click icon "plus-square"
    And I fill in "Name" with "is father of"
    And I fill in "Inversion" with "is son of"
    And I select "is ancestor of" from "Parent relation"
    And I select "is related to" from "Parent relation"
    And I select "person" from "Permitted type (from)"
    And I select "person" from "Permitted type (to)"
    And I press "Save"
    Then I should see "has been created"
    And relation "is father of" should have parent "is ancestor of"
    And relation "is father of" should have parent "is related to"

  @javascript
  Scenario: resolve one of multiple relation inheritances
    Given I am logged in as "admin"
    And the relation "is ancestor of/is descendent of" between "person/people" and "person/people"
    And the relation "is related to/is related to" between "person/people" and "person/people"
    And the relation "is father of/is son of" inheriting from "is ancestor of,is related to"
    When I go to the relations page
    And I click icon "edit" within "[data-is=kor-relations] tbody tr:nth-child(2)"
    And I unselect "is ancestor of" from "Parent relation"
    And I press "Save"
    Then I should see "has been changed"
    And relation "is father of" should not have parent "is ancestor of"
    And relation "is father of" should have parent "is related to"

  @javascript
  Scenario: try to create a relation inheritances with a conflict
    Given I am logged in as "admin"
    And the kind "person/people"
    And the relation "is ancestor of/is descendent of" between "person/people" and "person/people"
    When I go to the relations page
    And I click icon "plus-square"
    And I fill in "Name" with "is father of"
    And I fill in "Inversion" with "is son of"
    And I select "is ancestor of" from "Parent relation"
    And I select "person" from "Permitted type (from)"
    And I press "Save"
    Then I should see "the input contains errors"
    And I should see "cannot allow more endpoints than its ancestors"
