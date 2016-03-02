Feature: Configurable help
  As an admin
  In order to provide own help content to my users
  I want to be able to configure the help system with custom texts
  
  
  @javascript
  Scenario: See the configuration menu
    Given I am logged in as "admin"
    When I go to the config page
    Then I should see "Help" within ".layout_panel.left .section_panel"
    When I follow "Help" within ".layout_panel.left .section_panel"
    Then I should see "Simple search" within ".canvas"
    And I should see "Expert search" within ".canvas"
    And I should see "Multiple upload" within ".canvas"
    