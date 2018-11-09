Feature: Configurable help
  Scenario: See the configuration menu
    Given I am logged in as "admin"
    When I go to the config page
    Then I should see "Help"
    Then I should see "Search help text"
    And I should see "File upload help text"
    When I fill in "Profile help text" with "this is how to use this!"
    And I press "Save"
    When I follow "Edit profile"
    And I follow "help"
    Then I should see "this is how to use this!"
    