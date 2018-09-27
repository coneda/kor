Feature: authority groups

  @javascript
  Scenario: Authority Groups (no groups, not categories, list)
    Given I am logged in as "admin"
    When I go to the authority groups page
    Then I should see "Directories"
    And I should see "Global groups"
    And I should see no categories nor groups

  @javascript
  Scenario: create authority group
    Given I am logged in as "admin"
    When I go to the authority group categories page
    And I follow "create global group"
    And I fill in "Name" with "Brot"
    And I press "Save"
    Then I should see "Brot has been created"
    And I should see "Brot" within "kor-admin-groups"

  @javascript
  Scenario: edit authority group
    Given I am logged in as "admin"
    And the authority group "Brot"
    When I go to the authority group categories page
    And I follow "edit" within "kor-admin-groups"
    And I fill in "Name" with "Wurst"
    And I press "Save"
    Then I should see "Wurst has been changed"
    And I should see "Wurst" within "kor-admin-groups"

  @javascript
  Scenario: delete authority group
    Given I am logged in as "admin"
    And the authority group "Brot"
    When I go to the authority group categories page
    And I ignore the next confirmation box
    And I follow "delete" within "kor-admin-groups"
    Then I should see "Brot has been deleted"
    Then I should be on the authority group categories page
    Then I should not see "Brot" within "kor-admin-groups"

  @javascript
  Scenario: create authority group category
    Given I am logged in as "admin"
    When I go to the authority group categories page
    And I follow "create directory"
    And I fill in "Name" with "Frühstück"
    And I press "Save"
    Then I should see "Frühstück has been created"
    And I should see "Frühstück" within "[data-is=kor-admin-group-categories]"

  @javascript
  Scenario: edit authority group category
    Given I am logged in as "admin"
    And the authority group category "Frühstück"
    When I go to the authority group categories page
    And I follow "edit" within the row for authority group category "Frühstück"
    And I fill in "Name" with "Mittachmahl"
    And I press "Save"
    Then I should see "Mittachmahl has been changed"
    And I should see "Mittachmahl" within "[data-is=kor-admin-group-categories]"

  @javascript
  Scenario: delete authority group category
    Given I am logged in as "admin"
    And the authority group category "Frühstück"
    When I go to the authority group categories page
    And I ignore the next confirmation box
    And I follow "delete" within the row for authority group category "Frühstück"
    Then I should not see "Frühstück" within "[data-is=kor-admin-group-categories]"
    And I should be on the authority group categories page

  @javascript
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

  @javascript
  Scenario: delete deep authority group category
    Given I am logged in as "admin"
    And the authority group categories structure "top level >> Level 1 >> Level 2"
    When I go to the authority group categories page
    And I ignore the next confirmation box
    And I follow "delete" within the row for authority group category "top level"
    Then I should see "has been deleted"
    Then I should not see "Level 1" within "[data-is=kor-admin-group-categories]"
    And I should not see "Level 2" within "[data-is=kor-admin-group-categories]"

  @javascript
  Scenario: delete authority group category with deep authority group
    Given I am logged in as "admin"
    And the authority group category "level 1"
    And the authority group "level 1 Group" inside "level 1"
    When I go to the authority group categories page
    And I ignore the next confirmation box
    And I follow "delete" within the row for authority group category "level 1"
    Then I should see "has been deleted"
    Then I should not see "level 1" within "[data-is=kor-admin-group-categories]"
    And I should not see "level 1 Group" within "[data-is=kor-admin-group-categories]"

  @javascript
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
    Then I should see "Brot has been changed"
    And I should be on the authority group category page for "Mittachmahl"
    And I should see "Brot" within "kor-admin-groups"
    And I should see "top level » Mittachmahl"

  @javascript
  Scenario: download zip file
    Given I am logged in as "admin"
    And the authority group "Natur"
    And the authority group "Natur" contains a medium
    When I go to the authority group page for "Natur"
    And I follow "download group as zip file"
    When I go to the authority group page for "Natur"
    Then I should be on the authority group page for "Natur"
    
  @javascript
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
    
  @javascript
  Scenario: Add an authority group's entities to the clipboard as a normal user
    Given user "jdoe" is allowed to "view" collection "default" through credential "users"
    And I am logged in as "jdoe"
    And the entity "Mona Lisa" of kind "artwork/artworks"
    And the entity "Leonardo" of kind "person/people"
    And the authority group "some"
    And the entity "Leonardo" is in authority group "some"
    And the entity "Mona Lisa" is in authority group "some"
    When I go to the authority group page for "some"
    And I follow "add to clipboard" within "[data-is=kor-entity-group]"
    Then I should see "entities have been copied to the clipboard"
    When I go to the clipboard
    Then I should see "Mona Lisa"
    And I should see "Leonardo"