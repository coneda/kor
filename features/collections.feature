Feature: collections page

  Scenario: Merge one collection into another

  Scenario: create collection
    Given I am logged in as "admin"
    When I go to the collections page
    And I follow "create collection"
    And I fill in "Name" with "Socks"
    When I select "admins" from "Allow these groups to edit"
    When I select "students" from "Allow these groups to edit"
    And I press "Save"
    Then I should see "Socks" within widget "kor-collections"
    And there should be the collection named "Socks" in the database
    When I go to the collections page
    And I follow "edit" within the row for collection "Socks"
    Then the select "Allow these groups to edit" should have value "admins,students"


  Scenario: edit collection
    Given I am logged in as "admin"
    And the collection "Socks"
    When I go to the collections page
    And I follow "edit" within the row for collection "Socks"
    And I fill in "Name" with "Pants"
    And I press "Save"
    Then I should see "Pants" within widget "kor-collections"
    Then I should not see "Socks" within widget "kor-collections"
    And there should be the collection named "Pants" in the database
    And there should not be the collection named "Socks" in the database

  Scenario: delete an empty collection
    Given I am logged in as "admin"
    And the collection "Socks"
    When I go to the collections page
    And I ignore the next confirmation box
    And I follow "delete" within the row for collection "Socks"
    Then I should not see "Socks" within widget "kor-collections"
    And there should not be the collection named "Socks" in the database
    
  Scenario: Delete a non-empty collection
    Given I am logged in as "admin"
    And the entity "Mona Lisa" of kind "Werk/Werke" inside collection "Default"
    And I am on the collections page
    And I ignore the next confirmation box
    When I follow "delete" within the row for collection "Default"
    Then I should be on the collections page
    And I should see "can't be deleted"
    And I should see "Default" within widget "kor-collections"
    
  Scenario: Have a right for viewing meta data
    Given I am logged in as "admin"
    And I am on the collections page
    When I follow "create collection"
    Then I should see "Allow these groups to display the master data"
