Feature: personal collections
  Scenario: make user have a personal collection
    Given I am logged in as "admin"
    And I follow "Users"
    And I follow "edit" within the row for user "John Doe"
    And I check "Personal collection"
    And I press "Save"
    Then I should see "has been changed"
    And user "jdoe" should have a personal collection
    And I should see a check mark within the row for user "John Doe"
    And I follow "edit" within the row for user "John Doe"
    Then checkbox "Personal collection" should be checked

  Scenario: Create user with personal collection and check permissions
    Given user "jdoe" has a personal collection
    Then user "jdoe" should have the following access rights
      | collection | credential | policy             |
      | Default    | students   | view               |
      | jdoe       | jdoe       | create             |
      | jdoe       | jdoe       | delete             |
      | jdoe       | jdoe       | download_originals |
      | jdoe       | jdoe       | edit               |
      | jdoe       | jdoe       | tagging            |
      | jdoe       | jdoe       | view               |
      | jdoe       | jdoe       | view_meta          |
      
  Scenario: Edit a user with a personal collection
    Given user "jdoe" has a personal collection
    And I am logged in as "admin"
    And I follow "Users"
    When I follow "edit" within the row for user "John Doe"
    And I press "Save"
    Then user "jdoe" should have the following access rights
      | collection | credential | policy             |
      | Default    | students   | view               |
      | jdoe       | jdoe       | create             |
      | jdoe       | jdoe       | delete             |
      | jdoe       | jdoe       | download_originals |
      | jdoe       | jdoe       | edit               |
      | jdoe       | jdoe       | tagging            |
      | jdoe       | jdoe       | view               |
      | jdoe       | jdoe       | view_meta          |
  
  Scenario: Make a user non-personal again
    And I am logged in as "admin"
    And I follow "Users"
    When I follow "edit" within the row for user "John Doe"
    And I uncheck "Personal collection"
    And I press "Save"
      Then user "jdoe" should have the following access rights
      | collection | credential | policy |
      | Default    | students   | view   |
    When I go to the collections page
    Then I should not see "jdoe"
    
  Scenario: Try to make a user with a non-empty collection non-personal again
    Given user "jdoe" has a personal collection
    And entity "Mona Lisa" is in collection "jdoe"
    And I am logged in as "admin"
    And I follow "Users"
    When I follow "edit" within the row for user "John Doe"
    And I uncheck "Personal collection"
    And I press "Save"
    Then I should see "The personal collection could not be deleted because it still contains entities"
  
  Scenario: Show personal collectionsan edit link when there are personal collections
    Given user "jdoe" has a personal collection
    And I am logged in as "admin"
    When I go to the collections page
    Then I should see "jdoe (user: John Doe)"
    When I go to the users page
    And I follow "edit" within the row for user "John Doe"
    And I uncheck "Personal collection"
    And I press "Save"
    And I go to the collections page
    Then I should not see "jdoe"
    And I should not see "jdoe (user: John Doe)"
    
  Scenario: Change the mail address for a user with a personal collection
    Given user "jdoe" has a personal collection
    And I am logged in as "admin"
    When I go to the users page
    When I follow "edit" within the row for user "jdoe"
    And I fill in "E-mail" with "jdoe@miami.com"
    And I press "Save"
    And I should see a check mark within the row for user "John Doe"
    