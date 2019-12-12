Feature: domains page

  Scenario: Merge one domain into another

  Scenario: create domain
    Given I am logged in as "admin"
    When I go to the collections page
    And I follow "create domain"
    And I fill in "Name" with "Socks"
    And I press "Save"
    Then I should see "Socks" within widget "kor-collections"
    And there should be the collection named "Socks" in the database

  Scenario: edit domain
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

  Scenario: delete an empty domain
    Given I am logged in as "admin"
    And the collection "Socks"
    When I go to the collections page
    And I ignore the next confirmation box
    And I follow "delete" within the row for collection "Socks"
    Then I should not see "Socks" within widget "kor-collections"
    And there should not be the collection named "Socks" in the database
    
  Scenario: Delete a non-empty domain
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
    When I follow "create domain"
    Then I should see "Allow these groups to display the master data"
