Feature: credentials

  @javascript
  Scenario: User Groups (no groups, list)
    Given I am logged in as "admin"
    When I go to the credentials page
    Then I should see "User groups"
    And I should see no user groups

  @javascript
  Scenario: see credentials without authorization
    Given I am logged in as "john"
    When I go to the credentials page
    Then I should see "Access denied"
    
  @javascript
  Scenario: see credentials with authorization
    Given I am logged in as "admin"
    When I go to the credentials page
    Then I should see "User groups"

  @javascript
  Scenario: delete credential without authorization 
    Given I am logged in as "john"
    And the credential "Freaks" described by "The KOR-Freaks"
    When I go to the edit page for "credential" "Freaks"
    Then I should see "Access denied"

  @javascript
  Scenario: create credential
    Given I am logged in as "admin"
    When I go to the credentials page
    And I follow "Plus"
    And I fill in "credential[name]" with "Freaks"
    And I fill in "credential[description]" with "The KOR-Freaks"
    And I press "Create"
    Then I should see "Freaks"
    And I should see "The KOR-Freaks"

  @javascript
  Scenario: edit credential
    Given I am logged in as "admin"
    And the credential "Freaks" described by "The KOR-Freaks"
    When I go to the credentials page
    And I follow "Pen" within "table.kor_table tr:nth-child(3)"
    And I fill in "credential[name]" with "Kings"
    And I fill in "credential[description]" with "The KOR-Kings"
    And I press "Save"
    Then I should see "Kings"
    And I should see "The KOR-Kings"
    And I should not see "Freaks" within "table.kor_table"
    And I should not see "The KOR-Freaks"
  
  
  @javascript
  Scenario: delete credential
    Given I am logged in as "admin"
    And the credential "Freaks" described by "The KOR-Freaks"
    When I go to the credentials page
    And I ignore the next confirmation box
    And I follow "X" within the row for "credential" "Freaks"
    Then I should not see "Freaks"
    And I should not see "The KOR-Freaks"

  @javascript
  Scenario: collections & credentials
    Given I am logged in as "admin"
    And the collection "Hauptsammlung"
    And the credential "Freaks"
    When I go to the collections page
    And I follow "Pen" within the row for "collection" "Hauptsammlung"
    Then I should see "Freaks"
  
