Feature: Multi file upload
  As a user
  In order to save time while uploading data files
  I want a multi file uploader
  
  
  Scenario: Show the form
    Given I am logged in as "admin"
    And I go to the multi upload page
    Then I should see an input with the current date
