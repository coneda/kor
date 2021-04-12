Feature: Welcome
  Scenario: Welcome page as guest
    Given I am on the home page
    Then I should see "Welcome"
    And I should see "Welcome to ConedaKOR"
    And I should not see "Randomly selected entries"
    And I should not see "Mona Lisa"
    And I should not see "Leonardo"

  @elastic
  Scenario: Welcome as a logged in user
    Given the setting "welcome_page_only_media" is "false"
    Given I am logged in as "admin"
    And I am on the home page
    Then I should see "Welcome"
    And I should see "Welcome to ConedaKOR"
    And I should see "Randomly selected entries"
    And I should see a grid with "4" entities

    Given the setting "welcome_page_only_media" is "true"
    When I reload the page
    And I should see a grid with "2" entities

  Scenario: Show the 'report a problem' link to admins
    Given I am logged in as "admin"
    And I am on the home page
    Then I should see a link "Report a problem" leading to "github.com"

  Scenario: Show the 'report a problem' link to non-admins
    Given I am logged in as "jdoe"
    And I am on the home page
    Then I should see a link "Report a problem" leading to "admin@example.com"

  Scenario: Show the terms of use (don't show when empty)
    Given I am on the home page
    And I click "Terms of use"
    Then I should see "enter a legal notice here"

    Given I am logged in as "admin"
    When I click "Settings"
    And I fill in "Text for terms of use" with ""
    And I click "Save"
    Then I should see "changed"
    When I reload the page
    Then I should not see "Terms of use" within "kor-menu"
