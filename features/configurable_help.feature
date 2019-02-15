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
    

  @javascript
  Scenario: Per-locale help
    Given I am logged in as "admin"
    And I follow "Administration"
    And I follow "General"
    And I follow "Help"
    When I fill in "config_help_entities_multi_upload_en" with "English help"
    When I fill in "config_help_entities_multi_upload_de" with "Deutsche Hilfe"
    And I press "Save"
    When I follow "Multiple upload"
    And I follow "help"
    Then I should see "English help"
    When I follow "Edit profile"
    And I select "de" from "user_locale"
    And I press "Save"
    When I follow "Multiupload"
    And I follow "Hilfe"
    Then I should see "Deutsche Hilfe"
    