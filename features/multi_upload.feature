Feature: Multi file upload
  Scenario: Show the form
    Given "admin" has a user group "upload"
    Given I am logged in as "admin"
    And I go to the upload page
    Then I should see option "upload"

  Scenario: Obey max upload size configuration
    Given pending: not possible to test with webdriver yet

  # Scenario: only if you can create
