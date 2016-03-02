Feature: Generators
  In order to add arbitrary content to the entity pages
  As an admin
  I want to add markup generators

  @javascript
  Scenario: Create a generator
    Given I am logged in as "admin"
    And the kind "Work/Works"
    When I go to the kinds page
    And I follow "Globe" within the row for "kind" "Work"
    And I follow "Plus"
    And I fill in "generator[name]" with "gnd_link"
    And I fill in "generator[directive]" with "<span ng-bind='entity.id'></span>"
    And I press "Create"
    Then I should see "gnd_link" within ".layout_panel.left"


  @javascript
  Scenario: Add a generator that uses the current locale
    Given I am logged in as "admin"
    And the generator "language_indicator" for kind "Work/Works"
    And the entity "Mona Lisa" of kind "Work/Works"
    When I go to the entity page for "Mona Lisa"
    Then I should see "English"
    And I should not see "Deutsch"
    When I follow "Edit profile"
    And I select "de" from "user[locale]"
    And I press "Save"
    And I go to the entity page for "Mona Lisa"
    Then I should see "Deutsch"
    And I should not see "English"