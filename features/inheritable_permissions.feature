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
    And I press "Create"

    And I follow "Plus"
    And I fill in "user[full_name]" with "Hans Mustermann"
    And I fill in "user[name]" with "hmustermann"
    And I fill in "user[email]" with "hmustermann@coneda.net"
    And I fill in "user[parent_username]" with "jdor"
    And I press "Create"
    Then I should see "the user doesn't exist"
    And I fill in "user[parent_username]" with "jdoe"
    And I press "Create"
    Then I should not see "the user doesn't exist"

    And the user "hmustermann" has password "hmustermann"
    And I re-login as "hmustermann"
    And "Administration" is expanded
    Then I should see "Relations"


  @javascript
  Scenario: Inherit permissions, save the user and continue inheriting the value
    Given I am logged in as "admin"
    When I go to the users page
    And I follow "Plus"
    And I fill in "user[name]" with "jdoe"
    And I fill in "user[email]" with "jdoe@coneda.net"
    And I check "user[relation_admin]"
    And I check "user[active]"
    And I choose "user_extension_7"
    And I press "Create"
    And I follow "Plus"
    And I fill in "user[full_name]" with "Hans Mustermann"
    And I fill in "user[name]" with "hmustermann"
    And I fill in "user[email]" with "hmustermann@coneda.net"
    And I fill in "user[parent_username]" with "jdoe"
    And I press "Create"

    Then user "hmustermann@coneda.net" should be active
    And user "hmustermann@coneda.net" should have the role "relation_admin"
    And user "hmustermann@coneda.net" should expire at "7.days.from_now"

    When I go to the users page
    And I follow "Pen" within the row for "user" "hmustermann"
    And I press "Save"
    And I go to the users page
    And I follow "Pen" within the row for "user" "jdoe"
    And I uncheck "user[relation_admin]"
    And I uncheck "user[active]"
    And I choose "user_extension_never"
    And I press "Save"

    Then user "hmustermann@coneda.net" should not be active
    And user "hmustermann@coneda.net" should not have the role "relation_admin"
    And user "hmustermann@coneda.net" should not expire
