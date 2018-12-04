Feature: usergroups
  Scenario: create user group
    Given I am logged in as "admin"
    When I go to the new user group page
    And I fill in "Name" with "Leonardo"
    And I press "Save"
    Then I should see "personal group has been created"
    And I should see "Leonardo"
    When I go to the user group "Leonardo"
    Then I should see "Leonardo"
    And I should see "Personal group"
    And I should see "No entities found"

  Scenario: rename user group
    Given I am logged in as "admin"
    And the user group "Leonardo"
    When I go to the user groups page
    And I follow "edit"
    And I fill in "Name" with "Raffael"
    And I press "Save"
    Then I should see "Raffael"
    And I should not see "Leonardo"

  Scenario: delete user group
    Given I am logged in as "admin"
    And the user group "Leonardo"
    When I go to the user groups page
    And I ignore the next confirmation box
    And I follow "delete" within ".w-content"
    Then I should be on the user groups page
    Then I should not see "Leonardo"

  Scenario: share usergroup
    Given I am logged in as "admin"
    And the user group "Leonardo"
    When I go to the user groups page
    And I follow "share"
    Then I should see "Leonardo has been shared"
    When I go to the shared user groups page
    Then I should see "Leonardo"

  Scenario: unshare usergroup
    Given I am logged in as "admin"
    And the shared user group "Leonardo"
    When I go to the user groups page
    And I follow "unshare"
    Then I should be on the user groups page
    Then I should see "Leonardo is not shared anymore"
    When I go to the shared user groups page
    Then I should not see "Leonardo"

  Scenario: publish usergroup
    Given I am logged in as "admin"
    And the user group "Leonardo"
    When I go to the publishments page
    And I follow "create published group"
    And I fill in "Name" with "Leoforall"
    And I select "Leonardo" from "Personal group"
    And I press "Save"
    Then I should see "Leoforall"
    And I should see "pub" within "[data-is=kor-publishments]"

  Scenario: unpublish usergroup
    Given I am logged in as "admin"
    And the user group "Leonardo" published as "Leoforall"
    When I go to the publishments page
    And I ignore the next confirmation box
    And I follow "delete" within "[data-is=kor-publishments]"
    Then I should see "nothing found"
    
  Scenario: Renew a published usergroup
    Given I am logged in as "admin"
    And the user group "Leonardo" published as "Leonforall"
    And the entity "Mona Lisa" of kind "Werk/Werke"
    When I go to the entity page for "Mona Lisa"
    And I go to the publishments page
    And I follow "extend"
    Then I should be on the publishments page
    And I should see "has been extended"
    
  Scenario: Transfer a shared group to the clipboard
    Given I am logged in as "admin"
    And "admin" has a shared user group "MyStuff"
    And the first medium is inside user group "MyStuff"
    And user "john" is allowed to "view/edit" collection "Default" through credential "Freelancers"
    And I re-login as "john"
    And I am on the shared user groups page
    When I follow "MyStuff"
    Then I should see "Leonardo"
    When I follow "add to clipboard" within ".group-commands"
    And I go to the clipboard
    Then I should see element "img" within "[data-is=kor-clipboard]"
