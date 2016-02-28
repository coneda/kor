Feature: Multi file upload
  
  @javascript
  Scenario: Show the form
    Given I am logged in as "admin"
    And I go to the multi upload page
    Then I should see an input with the current date

  
  @javascript
  Scenario: Obey max upload size configuration
    Given pending: not possible to test with webdriver yet
