Feature: usergroups

  Scenario: User Groups (no groups, list)
    Given I am logged in as "admin"
    When I go to the credentials page
    Then I should see "Benutzergruppen"
    And I should see no user groups


  Scenario: create user group
    Given I am logged in as "admin"
    When I go to the new user group page
    And I fill in "user_group[name]" with "Leonardo"
    And I press "Erstellen"
    Then I should see "Leonardo wurde angelegt"
    And I should see "Leonardo"
    When I go to the user group "Leonardo"
    Then I should see "Leonardo"
    And I should see "Eigene Gruppe"
    And I should see "keine Entitäten"


  Scenario: rename user group
    Given I am logged in as "admin"
    And the user group "Leonardo"
    When I go to the user groups page
    And I follow "Pen"
    And I fill in "user_group[name]" with "Raffael"
    And I press "Speichern"
    Then I should see "Raffael"
    And I should not see "Leonardo"

  @javascript
  Scenario: delete user group
    Given I am logged in as "admin"
    And the user group "Leonardo"
    When I go to the user groups page
    And I follow the delete link within "tr.user_group"
    Then I should be on the user groups page
    Then I should not see "Leonardo"


  Scenario: share usergroup
    Given I am logged in as "admin"
    And the user group "Leonardo"
    When I go to the user groups page
    And I follow "Private"
    Then I should see "Leonardo wurde freigegeben"
    When I go to the shared user groups page
    Then I should see "Leonardo"


  Scenario: unshare usergroup
    Given I am logged in as "admin"
    And the shared user group "Leonardo"
    When I go to the user groups page
    And I follow "Public"
    Then I should be on the user groups page
    Then I should see "Leonardo ist nun nicht mehr freigegeben"
    When I go to the shared user groups page
    Then I should not see "Leonardo"


  Scenario: publish usergroup
    Given I am logged in as "admin"
    And the user group "Leonardo"
    When I go to the publishments page
    And I follow "Plus"
    And I fill in "publishment[name]" with "Leoforall"
    And I select "Leonardo" from "publishment[user_group_id]"
    And I press "Erstellen"
    Then I should see "Leoforall"
    And I should see "pub" within "table.kor_table"

  @javascript
  Scenario: unpublish usergroup
    Given I am logged in as "admin"
    And the user group "Leonardo" published as "Leoforall"
    When I go to the publishments page
    And I follow the delete link within "table.kor_table tr:nth-child(2)"
    Then I should see "es wurden keine veröffentlichte Gruppen gefunden"
    
    
  Scenario: Renew a published usergroup
    Given I am logged in as "admin"
    And the user group "Leonardo" published as "Leonforall"
    And the entity "Mona Lisa" of kind "Werk/Werke"
    When I go to the entity page for "Mona Lisa"
    And I go to the publishments page
    And I follow "Stop_watch" within the row for "publishment" "Leonforall"
    Then I should be on the publishments page
    
    
  Scenario: Transfer a shared group to the clipboard
    Given I am logged in as "admin"
    And Leonardo, Mona Lisa and a medium as correctly related entities
    And "admin" has a shared user group "MyStuff"
    And the first medium is inside user group "MyStuff"
    And user "john" is allowed to "view/edit" collection "Default" through credential "Freelancers"
    And I re-login as "john"
    And I am on the shared user groups page
    When I follow "MyStuff"
    Then I should see "Leonardo da Vinci"
    When I follow "Target"
    And I go to the clipboard
    Then I should see element "img" within ".canvas"
    
    
