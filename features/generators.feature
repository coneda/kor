Feature: Generators
  In order to add arbitrary content to the entity pages
  As an admin
  I want to add markup generators


  @javascript
  Scenario: Add a generator that uses the current locale
    Given I am logged in as "admin"
    And the generator "language_indicator" for kind "Work/Works"
    And the entity "Mona Lisa" of kind "Work/Works"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Deutsch"
    And I should not see "English"
    When I follow "Profil bearbeiten"
    And I select "en" from "user[locale]"
    And I press "Speichern"
    And I go to the entity page for "Mona Lisa"
    Then I should see "English"
    And I should not see "Deutsch"