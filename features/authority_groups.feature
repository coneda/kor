Feature: authority groups

  Scenario: Authority Groups
    Given I am logged in as "admin"
    When I go to the authority groups page
    Then I should see "Directories"
    And I should see "Global groups"
    And I should see "archive" within "[data-is=kor-admin-group-categories]"
    And I should not see "seminar" within "kor-admin-groups"

  Scenario: create authority group
    Given I am logged in as "admin"
    When I go to the authority group categories page
    And I follow "create global group"
    And I fill in "Name" with "Brot"
    And I press "Save"
    Then I should see "has been created"
    And I should see "Brot" within "kor-admin-groups"

  Scenario: edit authority group
    Given I am logged in as "admin"
    When I go to the authority group categories page
    And I follow "edit" within the row for authority group "lecture"
    And I fill in "Name" with "Wurst"
    And I press "Save"
    Then I should see "has been changed"
    And I should see "Wurst" within "kor-admin-groups"
    And I should not see "lecture" within "kor-admin-groups"

  Scenario: delete authority group
    Given I am logged in as "admin"
    When I go to the authority group categories page
    And I ignore the next confirmation box
    And I follow "delete" within the row for authority group "lecture"
    Then I should see "has been deleted"
    Then I should be on the authority group categories page
    Then I should not see "lecture" within "kor-admin-groups"

  Scenario: create authority group category
    Given I am logged in as "admin"
    When I go to the authority group categories page
    And I follow "create directory"
    And I fill in "Name" with "Frühstück"
    And I press "Save"
    Then I should see "has been created"
    And I should see "Frühstück" within "[data-is=kor-admin-group-categories]"

  Scenario: edit authority group category
    Given I am logged in as "admin"
    When I go to the authority group categories page
    And I follow "edit" within the row for authority group category "archive"
    And I fill in "Name" with "Mittachmahl"
    And I press "Save"
    Then I should see "has been changed"
    And I should see "Mittachmahl" within "[data-is=kor-admin-group-categories]"
    And I wait for "1" second
    And I should not see "archive" within "[data-is=kor-admin-group-categories]"

  Scenario: delete authority group category
    Given I am logged in as "admin"
    When I go to the authority group categories page
    And I ignore the next confirmation box
    And I follow "delete" within the row for authority group category "archive"
    Then I should not see "archive" within "[data-is=kor-admin-group-categories]"
    And I should be on the authority group categories page

  Scenario: create deep authority group category
    Given I am logged in as "admin"
    When I go to the authority group categories page
    And I follow "create directory"
    And I fill in "Name" with "Level 1"
    And I press "Save"
    And I follow "Level 1"
    Then I should see "top level » Level 1"
    When I follow "create directory"
    And I fill in "Name" with "Level 2"
    And I press "Save"
    And I follow "Level 2"
    Then I should see "top level » Level 1 » Level 2"

  Scenario: delete deep authority group category
    And the authority group categories structure "top level >> Level 1 >> Level 2"
    Given I am logged in as "admin"
    When I go to the authority group categories page
    And I ignore the next confirmation box
    And I follow "delete" within the row for authority group category "top level"
    Then I should see "has been deleted"
    Then I should not see "Level 1" within "[data-is=kor-admin-group-categories]"
    And I should not see "Level 2" within "[data-is=kor-admin-group-categories]"

  Scenario: delete authority group category with deep authority group
    And the authority group category "level 1"
    And the authority group "l1 Group" inside "level 1"
    Given I am logged in as "admin"
    When I go to the authority group categories page
    And I ignore the next confirmation box
    And I follow "delete" within the row for authority group category "level 1"
    Then I should see "has been deleted"
    Then I should not see "level 1" within "[data-is=kor-admin-group-categories]"
    And I should not see "l1 Group" within "[data-is=kor-admin-group-categories]"

  Scenario: move authority group
    Given I am logged in as "admin"
    And the authority group category "Frühstück"
    And the authority group category "Mittachmahl"
    And the authority group "Brot" inside "Frühstück"
    When I go to the authority group categories page
    And I follow "Frühstück" within "[data-is=kor-admin-group-categories]"
    And I follow "edit" within the row for authority group "Brot"
    And I select "Mittachmahl" from "Directory"
    And I press "Save"
    Then I should see "has been changed"
    And I should be on the authority group category page for "Mittachmahl"
    And I should see "Brot" within "kor-admin-groups"
    And I should see "top level » Mittachmahl"

    # move to top level
    When I follow "edit"
    And I select "none" from "Directory"
    And I press "Save"
    When I follow "Global groups"
    And I should see "Brot" within "kor-admin-groups"

  Scenario: download zip file
    And the authority group "Natur"
    And the authority group "Natur" contains a medium
    Given I am logged in as "admin"
    When I go to the authority group page for "Natur"
    And I follow "download group as zip file"
    When I go to the authority group page for "Natur"
    Then I should be on the authority group page for "Natur"
    
  Scenario: Authority Groups (no, groups, no categories, create both)
    Given I am logged in as "admin"
    Given I am on the authority groups page
    When I follow "create directory"
    And I fill in "Name" with "Test Category"
    And I press "Save"
    Then I should be on the authority groups page
    And I should see "Test Category"
    When I follow "Test Category"
    Then I should see "top level » Test Category"
    When I follow "create global group"
    And I fill in "Name" with "Test Authority Group"
    And I press "Save"
    Then I should be on the authority group category page for "Test Category"
    And I should see "Test Authority Group"
    
  Scenario: Add an authority group's entities to the clipboard as a normal user
    And I am logged in as "jdoe"
    And the authority group "some"
    And the entity "Leonardo" is in authority group "some"
    And the entity "Mona Lisa" is in authority group "some"
    When I go to the authority group page for "some"
    And I follow "add to clipboard" within "[data-is=kor-entity-group]"
    Then I should see "entities have been copied to the clipboard"
    When I go to the clipboard
    Then I should see "Mona Lisa"
    And I should see "Leonardo"

  Scenario: Remove entity
    And I am logged in as "jdoe"
    And the entity "Leonardo" is in authority group "lecture"
    When I follow "Global groups"
    And I follow "lecture"
    Then I should see "Leonardo"
    And I should not see link "remove"
    When I re-login as "admin"
    When I follow "Global groups"
    And I follow "lecture"
    Then I should see "Leonardo"
    When I follow "remove" within the cell for entity "Mona Lisa"
    Then I should see "have been removed"
    When I follow "remove"
    And I should see "No entities found"
