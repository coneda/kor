Feature: Exception logs
  As an admin
  In order to see what went wrong during a request
  I want to have a page which lists request errors
  
  
  Scenario: Show the exception logs
    Given user "admin" is a "developer"
    And I am logged in as "admin"
    When I go to the exception logs page
    Then I should see "Error report"
