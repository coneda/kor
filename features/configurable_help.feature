Feature: Configurable help
  Scenario: See the configuration menu
    Given I am logged in as "admin"
    When I go to the config page
    Then I should see "Help"
    Then I should see "Search help text"
    And I should see "File upload help text"
    When I fill in "General help text (menu) - en" with "do like this in general"
    When I fill in "Search help text - en" with "this is how to use this!"
    And I press "Save"
    Then I should see "changed"

    When I follow "Edit profile"

    When I follow "Help"
    Then I should see "do like this in general"
    Then I press the "escape" key

    When I follow "Search"
    And I follow "help"
    Then I should see "this is how to use this!"
