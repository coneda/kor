Feature: Inheritable permissions
  Scenario: Inherit permissions, login and use the menu
    Given user 'jdoe' is a relation admin
    And I am logged in as "admin"

    When I go to the users page
    And I follow "add"
    And I fill in "Full name" with "Hans Mustermann"
    And I fill in "Username" with "hmustermann"
    And I fill in "E-mail" with "hmustermann@coneda.net"
    And I check "Active"
    And I press "Expires in 7 days"
    And I fill in "Inherit permissions from" with "jdor"
    And I press "Save"
    Then I should see "the user doesn't exist"
    And I fill in "Inherit permissions from" with "jdoe"
    And I press "Save"
    Then I should see "has been created"
    Then I should not see "the user doesn't exist"

    Then user "hmustermann" should expire at "7.days.from_now"

    Given the user "hmustermann" has password "hmustermann"
    And I re-login as "hmustermann"
    When I go to the relations page
    Then I should see link "add"


  Scenario: Inherit permissions, save the user and continue inheriting the value
    Given user "jdoe" is a relation admin
    And I am logged in as "admin"

    When I go to the users page
    And I follow "add"
    And I fill in "Full name" with "Hans Mustermann"
    And I fill in "Username" with "hmustermann"
    And I fill in "E-mail" with "hmustermann@coneda.net"
    And I check "Active"
    And I press "Expires in 7 days"
    And I fill in "Inherit permissions from" with "jdoe"
    And I press "Save"

    Then user "hmustermann" should be active
    And user "hmustermann" should have the role "relation_admin"
    And user "hmustermann" should expire at "7.days.from_now"

    When I go to the users page
    And I follow "edit" within the row for user "hmustermann"
    And I press "Save"

    And I go to the users page
    And I follow "edit" within the row for user "jdoe"
    And I uncheck "Create and edit relations"
    And I uncheck "Active"
    And I press "Doesn't expire"
    And I press "Save"
    
    Then user "hmustermann" should not be active
    And user "hmustermann" should not have the role "relation_admin"
    And user "hmustermann" should not expire
