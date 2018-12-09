Feature: relations
  Scenario: create relation
    Given I am logged in as "admin"
    When I go to the relations page
    And I click icon "add"
    And I fill in "Name" with "loves"
    And I fill in "Inversion" with "loves not"
    And I fill in "Description" with "love"
    And I ignore the next confirmation box
    And I press "Save"
    Then I should see "loves" within widget "kor-relations"
    And I should see "loves not" within widget "kor-relations"
    And I should see "love" within widget "kor-relations"

  Scenario: edit relation
    Given I am logged in as "admin"
    And the relation "loves/is being loved by" between "person/people" and "person/people"
    When I go to the relations page
    And I click icon "edit" within the row for relation "loves"
    And I fill in "Name" with "hates"
    And I fill in "Inversion" with "hates not"
    And I fill in "Description" with "hate"
    And I ignore the next confirmation box
    And I press "Save"
    Then I should see "hates" within widget "kor-relations"
    And I should see "hates not" within widget "kor-relations"
    And I should see "hate" within widget "kor-relations"
    And I should not see "loves" within widget "kor-relations"
    And I should not see "loves not" within widget "kor-relations"
    And I should not see "love" within widget "kor-relations"

  Scenario: delete relation
    Given I am logged in as "admin"
    And the relation "loves/is being loved by" between "person/people" and "person/people"
    When I go to the relations page
    And I ignore the next confirmation box
    And I click icon "delete" within the row for relation "loves"
    Then I should not see "loves / is being loved by"

  Scenario: Empty relation list
    Given there are no relations
    And I am logged in as "admin"
    And I go to the relations page
    Then I should not see "Reverse name"
    And I should see "No relations found"

  Scenario: make relation inherit from another
    Given I am logged in as "admin"
    And the relation "is ancestor of/is descendent of" between "person/people" and "person/people"
    When I go to the relations page
    And I click icon "add"
    And I fill in "Name" with "is father of"
    And I fill in "Inversion" with "is son of"
    And I select "is ancestor of" from "Parent relation"
    And I select "person" from "Permitted type (from)"
    And I select "person" from "Permitted type (to)"
    And I press "Save"
    Then I should see "has been created"
    And relation "is father of" should have parent "is ancestor of"

  Scenario: resolve relation inheritance
    Given I am logged in as "admin"
    And the relation "is ancestor of/is descendent of" between "person/people" and "person/people"
    And the relation "is father of/is son of" inheriting from "is ancestor of"
    When I go to the relations page
    And I click icon "edit" within the row for relation "is father of"
    And I unselect "is ancestor of" from "Parent relation"
    And I select "person" from "Permitted type (from)"
    And I select "person" from "Permitted type (to)"
    And I press "Save"
    Then I should see "has been changed"
    And relation "is father of" should not have parent "is ancestor of"

  Scenario: make relation inherit from multiple others
    Given I am logged in as "admin"
    And the relation "is ancestor of/is descendent of" between "person/people" and "person/people"
    And the relation "is closely related to/is closely related to" between "person/people" and "person/people"
    When I go to the relations page
    And I click icon "add"
    And I fill in "Name" with "is father of"
    And I fill in "Inversion" with "is son of"
    And I select "is ancestor of" from "Parent relation"
    And I select "is closely related to" from "Parent relation"
    And I select "person" from "Permitted type (from)"
    And I select "person" from "Permitted type (to)"
    And I press "Save"
    Then I should see "has been created"
    And relation "is father of" should have parent "is ancestor of"
    And relation "is father of" should have parent "is closely related to"

  Scenario: resolve one of multiple relation inheritances
    Given I am logged in as "admin"
    And the relation "is ancestor of/is descendent of" between "person/people" and "person/people"
    And the relation "is closely related to/is closely related to" between "person/people" and "person/people"
    And the relation "is father of/is son of" inheriting from "is ancestor of,is closely related to"
    When I go to the relations page
    And I click icon "edit" within the row for relation "is father of"
    Then options "is ancestor of,is closely related to" from "Parent relation" should be selected
    When I unselect "is ancestor of" from "Parent relation"
    And I press "Save"
    Then I should see "has been changed"
    And relation "is father of" should not have parent "is ancestor of"
    And relation "is father of" should have parent "is closely related to"

  Scenario: try to create a relation inheritances with a conflict
    Given I am logged in as "admin"
    And the kind "person/people"
    And the relation "is ancestor of/is descendent of" between "person/people" and "person/people"
    When I go to the relations page
    And I click icon "add"
    And I fill in "Name" with "is father of"
    And I fill in "Inversion" with "is son of"
    And I select "is ancestor of" from "Parent relation"
    And I select "person" from "Permitted type (from)"
    And I press "Save"
    Then I should see "the input contains errors"
    And I should see "can't allow more endpoints than its ancestors"
