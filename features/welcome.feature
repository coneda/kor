Feature: Welcome
  Scenario: Welcome page as guest
    Given I am on the home page
    Then I should see "Welcome"
    And I should see "Welcome to ConedaKOR"
    And I should not see "Randomly selected entries"
    And I should not see "Mona Lisa"
    And I should not see "Leonardo"

  Scenario: Welcome as a logged in user
    Given I am logged in as "admin"
    And I am on the home page
    Then I should see "Welcome"
    And I should see "Welcome to ConedaKOR"
    And I should see "Randomly selected entries"
    And I should see a grid with "4" entities

  Scenario: Show the 'report a problem' link to admins
    Given I am logged in as "admin"
    And I am on the home page
    Then I should see a link "Report a problem" leading to "github.com"

  Scenario: Show the 'report a problem' link to non-admins
    Given I am logged in as "jdoe"
    And I am on the home page
    Then I should see a link "Report a problem" leading to "admin@example.com"

  Scenario: Don't show the clipboard to guests
    And user "guest" is allowed to "view" collection "default" via credential "guests"
    When I go to the welcome page
    Then I should not see "Clipboard" within "kor-menu"
    And I should not see "Session"
    When I go to the entity page for "Mona Lisa"
    Then I should not see "Clipboard"
    And I should not see link "Target"

  Scenario: Use custom html on the welcome page
    When I am logged in as "admin"
    And I should see "Admin" within widget "kor-menu"
    And I follow "Settings"
    And I fill in "welcome_text" with "<h1>Benvenuto!</h1><br/><br/><a href='https://custom.example.com'>custom</a>"
    And I press "Save"
    And I go to the welcome page
    Then I should see a link "custom" leading to "https://custom.example.com"

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
