Feature: Manage user preferences
  Scenario: change locale
    Given I am logged in as "admin"
    And I follow "Edit profile"
    Then field "Language" should have value "en"
    When I select "de" from "Language"
    And I press "Save"
    When I reload the page
    Then I should see "Benutzer"
