Feature: credentials
  Scenario: User Groups (no groups, list)
    Given I am logged in as "admin"
    When I go to the credentials page
    Then I should see "User groups"
    And I should see no user groups

  Scenario: see credentials without authorization
    Given I am logged in as "jdoe"
    When I go to the credentials page
    Then I should see "Access denied"
    
  Scenario: see credentials with authorization
    Given I am logged in as "admin"
    When I go to the credentials page
    Then I should see "User groups"

  Scenario: create credential
    Given I am logged in as "admin"
    When I go to the credentials page
    Then I should see "students"
    When I follow "create user group"
    And I fill in "Name" with "Freaks"
    And I fill in "Description" with "The KOR-Freaks"
    And I press "Save"
    Then I should see "Freaks"
    And I should see "The KOR-Freaks"

  Scenario: edit credential
    Given I am logged in as "admin"
    And the credential "Freaks" described by "The KOR-Freaks"
    When I go to the credentials page
    And I follow "edit" within the row for credential "Freaks"
    And I fill in "Name" with "Kings"
    And I fill in "Description" with "The KOR-Kings"
    And I press "Save"
    Then I should see "Kings"
    And I should see "The KOR-Kings"
    And I should not see "Freaks"
    And I should not see "The KOR-Freaks"
  
  Scenario: delete credential
    Given I am logged in as "admin"
    And the credential "Freaks" described by "The KOR-Freaks"
    When I go to the credentials page
    And I ignore the next confirmation box
    And I follow "delete" within the row for credential "Freaks"
    Then I should not see "Freaks"
    And I should not see "The KOR-Freaks"

  Scenario: collections & credentials
    Given I am logged in as "admin"
    And the collection "Hauptsammlung"
    And the credential "Freaks"
    When I go to the collections page
    And I follow "edit" within the row for collection "Hauptsammlung"
    Then I should see "Freaks"
