Feature: personal collections
  Scenario: create a personal collection
    Given I am logged in as "admin"
    When I go to the new user group page
    And I fill in "Name" with "Leonardo"
    And I press "Save"
    Then I should see "has been created"
    And I should see "Leonardo"
    When I go to the user group "Leonardo"
    Then I should see "Leonardo"
    And I should see "Personal collection"
    And I should see "No entities found"

  Scenario: rename a personal collection
    Given I am logged in as "admin"
    And the user group "Leonardo"
    When I go to the user groups page
    Then I should see "Personal collections"
    And I save a screenshot
    And I follow "edit"
    And I fill in "Name" with "Raffael"
    And I press "Save"
    Then I should see "Raffael"
    And I should not see "Leonardo"

  Scenario: delete a personal collection
    Given I am logged in as "admin"
    And the user group "Leonardo"
    When I go to the user groups page
    Then I should see "Personal collections"
    And I ignore the next confirmation box
    And I follow "delete" within ".w-content"
    Then I should be on the user groups page
    Then I should not see "Leonardo"

  Scenario: share a personal collection
    Given I am logged in as "admin"
    And the user group "Leonardo"
    When I go to the user groups page
    And I follow "share"
    Then I should see "Leonardo has been shared"
    When I go to the shared user groups page
    Then I should see "Leonardo"

  Scenario: unshare a personal collection
    Given I am logged in as "admin"
    And the shared user group "Leonardo"
    When I go to the user groups page
    And I follow "unshare"
    Then I should be on the user groups page
    Then I should see "Leonardo is not shared anymore"
    When I go to the shared user groups page
    Then I should not see "Leonardo"

  Scenario: publish a personal collection
    Given I am logged in as "admin"
    And the user group "Leonardo"
    When I go to the publishments page
    And I follow "create published collection"
    And I fill in "Name" with "Leoforall"
    And I select "Leonardo" from "Personal collection"
    And I press "Save"
    Then I should see "Leoforall"
    And I should see "pub" within "[data-is=kor-publishments]"

  Scenario: unpublish a personal collection
    Given I am logged in as "admin"
    And the user group "Leonardo" published as "Leoforall"
    When I go to the publishments page
    And I ignore the next confirmation box
    And I follow "delete" within "[data-is=kor-publishments]"
    Then I should see "nothing found"
    
  Scenario: Renew a published collection
    Given I am logged in as "admin"
    And the user group "Leonardo" published as "Leonforall"
    And the entity "Mona Lisa" of kind "Werk/Werke"
    When I go to the entity page for "Mona Lisa"
    And I go to the publishments page
    And I follow "extend"
    Then I should be on the publishments page
    And I should see "has been extended"
    
  Scenario: Transfer a shared collection to the clipboard
    Given I am logged in as "admin"
    And "admin" has a shared user group "MyStuff"
    And the first medium is inside user group "MyStuff"
    And user "john" is allowed to "view/edit" collection "Default" through credential "Freelancers"
    And I re-login as "john"
    And I am on the shared user groups page
    When I follow "MyStuff"
    Then I should see "Leonardo"
    When I follow "add to clipboard" within ".group-commands"
    And I should see "the entities have been added to the clipboard"
    And I go to the clipboard
    Then I should see "Clipboard"
    And I should see element "img" within widget "kor-clipboard"

  Scenario: Add a global collection's entities to the clipboard as a normal user
    Given I am logged in as "jdoe"
    And the entity "Louvre" is in authority group "lecture"
    And the entity "Mona Lisa" is in authority group "lecture"
    When I follow "Global collections"
    And I follow "lecture"
    Then I should see "Mona Lisa"
    And I follow "add to clipboard" within ".group-commands"
    Then I should see "the entities have been added to the clipboard"
    When I follow "Clipboard"
    Then I should see "Mona Lisa"
    And I should see "Louvre"
    
  Scenario: show a personal collection without permissions
    Given I am logged in as "mrossi"
    And I go to the user group "nice"
    Then I should see "Access denied"

  Scenario: Download as zip (foreground)
    Given I am logged in as "jdoe"
    When I follow "Personal collections"
    And I follow "nice"
    And I follow "download collection as zip file"
    # no error => we are happy

  Scenario: Download as zip (background)
    Given the setting "max_foreground_group_download_size" is "0.1"
    Given I am logged in as "jdoe"
    When I follow "Personal collections"
    And I follow "nice"
    And I follow "download collection as zip file"
    # this is not reliable, perhaps remove
    # Then I should see "Zip file will be created"
    And I wait for "1" second
    And there should be "1" outgoing email
    When I click the download link in mail "1"
    # no error => we are happy

  Scenario: Remove entity
    And I am logged in as "jdoe"
    And the entity "Leonardo" is in user group "nice"
    When I follow "Personal collections"
    And I follow "nice"
    Then I should see "Leonardo"
    When I follow "remove" within the cell for entity "Mona Lisa"
    Then I should see "have been removed"
    When I follow "remove"
    And I should see "No entities found"
