Feature: Inheritable permissions
  In order to save time on user maintenance
  As an admin
  I want to propagate permissions from one user to many others

  @javascript
  Scenario: Inherit permissions, login and use the menu
    Given I am logged in as "admin"
    When I go to the users page

    And I follow "Plus"
    And I fill in "user[name]" with "jdoe"
    And I fill in "user[email]" with "jdoe@coneda.net"
    And I check "user[relation_admin]"
    And I press "Erstellen"

    And I follow "Plus"
    And I fill in "user[full_name]" with "Hans Mustermann"
    And I fill in "user[name]" with "hmustermann"
    And I fill in "user[email]" with "hmustermann@coneda.net"
    And I fill in "user[parent_username]" with "jdor"
    And I press "Erstellen"
    Then I should see "der Benutzer existiert nicht"
    And I fill in "user[parent_username]" with "jdoe"
    And I press "Erstellen"
    Then I should not see "der Benutzer existiert nicht"

    And the user "hmustermann" has password "hmustermann"
    And I re-login as "hmustermann"
    And "Einstellungen" is expanded
    Then I should see "Relationen"
