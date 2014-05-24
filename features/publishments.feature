Feature: Publishments
  In order to show their user groups to friends
  Users should be able to
  Publish user groups to outside of the application
  
  
  Scenario: Create a Publishment
    Given I am logged in as "admin"
    And the user group "Test Group"
    When I go to the new publishment page
    Then I should see "Veröffentlichte Gruppe anlegen"
    When I fill in "publishment[name]" with "Test Publishment"
    And I press "Erstellen"
    Then I should be on the publishments page
    And I should see "Test Publishment"
    
  
  Scenario: Try to create a publishment without a name
    Given I am logged in as "admin"
    And the user group "Test Group"
    When I go to the new publishment page
    Then I should see "Veröffentlichte Gruppe anlegen"
    When I fill in "publishment[name]" with ""
    And I press "Erstellen"
    And I should see "Bezeichnung muss ausgefüllt werden"
