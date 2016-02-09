Feature: collections page

  Scenario: create collection
    Given I am logged in as "admin"
    When I go to the collections page
    And I follow "Plus"
    And I fill in "collection[name]" with "Socks"
    And I press "Create"
    Then I should see "Socks" within "table.kor_table"
    And there should be the collection named "Socks" in the database


  Scenario: edit collection
    Given I am logged in as "admin"
    And the collection "Socks"
    When I go to the collections page
    And I follow "Pen" within "table.kor_table tr:nth-child(3)"
    And I fill in "collection[name]" with "Pants"
    And I press "Save"
    Then I should see "Pants" within "table.kor_table"
    Then I should not see "Socks" within "table.kor_table"
    And there should be the collection named "Pants" in the database
    And there should not be the collection named "Socks" in the database


  @javascript
  Scenario: delete collection
    Given I am logged in as "admin"
    And the collection "Socks"
    When I go to the collections page
    When I follow the delete link within the row for "collection" "Socks"
    Then I should not see "Socks" within "table.kor_table"
    And there should not be the collection named "Socks" in the database
    

  @javascript    
  Scenario: Delete an empty collection
    Given I am logged in as "admin"
    And the collection "Empty collection"
    And I am on the collections page
    When I follow the delete link within the row for "collection" "Empty collection"
    Then I should be on the collections page
    And I should not see "Empty collection" within "table.kor_table"
    

  @javascript  
  Scenario: Delete an empty collection
    Given I am logged in as "admin"
    And the entity "Mona Lisa" of kind "Werk/Werke" inside collection "Default"
    And I am on the collections page
    When I follow the delete link within the row for "collection" "Default"
    Then I should be on the collections page
    And I should see "cannot be deleted"
    And I should see "Default" within "table.kor_table"
    
  
  @javascript
  Scenario: Have a right for viewing meta data
    Given I am logged in as "admin"
    And I am on the collections page
    When I follow "Plus"
    Then I should see "Allow these groups to display the master data"
