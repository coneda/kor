Feature: Exception logs
  
  Scenario: Show the exception logs
    Given user "admin" is a "admin"
    And I am logged in as "admin"
    When I go to the exception logs page
    Then I should see "Error report"
