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
    And I should see "Mona Lisa"
    And I should see "Leonardo"

  Scenario: Show the 'report a problem' link to admins
    Given I am logged in as "admin"
    And I am on the home page
    Then I should see a link "Report a problem" leading to "github.com"

  Scenario: Show the 'report a problem' link to non-admins
    Given I am logged in as "jdoe"
    And I am on the home page
    Then I should see a link "Report a problem" leading to "admin@example.com"
