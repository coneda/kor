# encoding: utf-8

Feature: Authentication and Authorization
  In order to have different responsabilities
  As a User
  I should have to authenticate and be authorized accordingly
  
  
  Scenario: Reset password with wrong email address
    When I go to the login page
    And I follow "Passwort vergessen?"
    And I fill in "email" with "does@not.exist"
    And I press "zurücksetzen"
    Then I should see "konnte nicht gefunden werden"


  Scenario: Reset password with correct email address
    Given the user "jdoe"
    When I go to the login page
    And I follow "Passwort vergessen?"
    And I fill in "email" with "jdoe@example.com"
    And I press "zurücksetzen"
    Then I should see "Ihr Passwort wurde neu generiert und an die angegebenen Emaildresse gesendet"
    
    
  Scenario: Reset admin password
    When I go to the login page
    And I follow "Passwort vergessen?"
    And I fill in "email" with "admin@coneda.net"
    And I press "zurücksetzen"
    Then I should see "konnte nicht gefunden werden"
  
  
  Scenario: Login after a session timeout
    Given I am logged in as "admin"
    And the entity "Mona Lisa" of kind "Werk/Werke"
    And the session has expired
    When I go to the entity page for "Mona Lisa"
    Then I should be on the login page
    When I fill in "username" with "admin"
    And I fill in "password" with "admin"
    And I press "Anmelden"
    Then I should be on the entity page for "Mona Lisa"

  
  Scenario: see credentials without authorization
    Given I am logged in as "john"
    When I go to the credentials page
    Then I should see "Der Zugriff wurde verweigert"


  Scenario: create credential without authorization
    Given I am logged in as "john"
    When I send the credential "name:Freaks,description:The KOR-Freaks"
    Then I should see "Der Zugriff wurde verweigert"


  Scenario: delete credential without authorization	
    Given I am logged in as "john"
    And the credential "Freaks" described by "The KOR-Freaks"
    When I go to the edit page for "credential" "Freaks"
    Then I should see "Der Zugriff wurde verweigert"

    
  Scenario Outline: Direct Actions
    Given I am logged in as "<username>"
    When I send a "<method>" request to "<url>" with params "<params>"
    Then I should get access "<access>"
    
    Examples:
      | username | method | url    | params | access |
      | admin    | GET    | /kinds |        | yes    |
      | john     | GET    | /kinds |        | no     |

  
  @javascript
  Scenario: Don't show group menu when not logged in
    Given the user "guest"
    And I am on the root page
    Then I should not see "Gruppen"

