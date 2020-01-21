Feature: Configurable help
  Scenario: See the configuration menu
    Given I am logged in as "admin"
    When I go to the config page
    Then I should see "Help"
    Then I should see "Search help text"
    And I should see "File upload help text"
    When I fill in "Profile help text" with "this is how to use this!"
    And I press "Save"
    Then I should see "changed"
    When I follow "Search"
    When I follow "Edit profile"
    And I save a screenshot
    Then I should see "Edit profile" within ".w-content"
    And I follow "help"
    Then I should see "this is how to use this!"
