Feature: Config
  Scenario: Show the configuration sections
    Given I am logged in as "admin"
    And I am on the config page
    Then I should see "Branding and display"
    And I should see "Behavior"
    And I should see "Other"
    And I should see "Maintainer organization"
    
  Scenario: Change a configuration option
    Given I am logged in as "admin"
    And I am on the config page
    And I fill in "Maintainer email address" with "me@example.com"
    And I press "Save"
    Then I should see "has been changed"
    And the config value "maintainer_mail" should be "me@example.com"

  Scenario: Show federation auth button if a label is configured
    Given the setting "env_auth_button_label" is "fed login"
    When I go to the login page
    Then I should see link "fed login"

  Scenario: Show federation auth button if a label is configured
    Given the setting "env_auth_button_label" is ""
    When I go to the login page
    Then I should not see link "federated login"