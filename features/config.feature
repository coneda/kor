Feature: Config
  As a admin
  In order to change the KOR configuration online
  I want to use a configuration editor
  
  @javascript
  Scenario: Show the configuration sections
    Given I am logged in as "admin"
    And I am on the config page
    Then I should see "Site operator"
    And I should see "Server"
    And I should see "Application"
    When I follow "Site operator"
    Then I should see element "input[name='config[maintainer][mail]']"
    
    
  @javascript
  Scenario: Change a configuration option
    Given I am logged in as "admin"
    And I am on the config page
    And I follow "Site operator"
    And I fill in "config[maintainer][mail]" with "me@example.com"
    And I press "Save"
    Then the application config file should include "maintainer.mail" with "me@example.com"
