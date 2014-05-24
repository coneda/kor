Feature: Config
  As a admin
  In order to change the KOR configuration online
  I want to use a configuration editor
  
  @javascript
  Scenario: Show the configuration sections
    Given I am logged in as "admin"
    And I am on the config page
    Then I should see "Seitenbetreiber"
    And I should see "Server"
    And I should see "Email"
    And I should see "Anwendung"
    When I follow "Seitenbetreiber"
    Then I should see element "input[name='config[maintainer][mail]']"
    
    
  @javascript
  Scenario: Change a configuration option
    Given I am logged in as "admin"
    And I am on the config page
    And I follow "Seitenbetreiber"
    And I fill in "config[maintainer][mail]" with "me@example.com"
    And I press "Sichern"
    Then the application config file should include "maintainer.mail" with "me@example.com"
