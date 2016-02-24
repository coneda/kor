Feature: Multi file upload
  
  @javascript
  Scenario: Show the form
    Given I am logged in as "admin"
    And I go to the multi upload page
    Then I should see an input with the current date

  
  @javascript
  Scenario: Obey max upload size configuration
    Given I am logged in as "admin"
    And the config option "max_file_upload_size" is set to "0.5"
    And I go to the multi upload page
    Then I should see an input with the current date
    When I follow "» Add files"
    And I select "/etc/passwd"