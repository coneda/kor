Feature: Authentication and Authorization
  In order to have different responsabilities
  As a User
  I should have to authenticate and be authorized accordingly
  
  
  Scenario: Reset password with wrong email address
    When I go to the login page
    And I follow "forgot your password?"
    And I fill in "email" with "does@not.exist"
    And I press "reset"
    Then I should see "could not be found"


  Scenario: Reset password with correct email address
    Given the user "jdoe"
    When I go to the login page
    And I follow "forgot your password?"
    And I fill in "email" with "jdoe@example.com"
    And I press "reset"
    Then I should see "A new passowrd has been created and sent to the entered email address"
    
    
  Scenario: Reset admin password
    When I go to the login page
    And I follow "forgot your password?"
    And I fill in "email" with "admin@coneda.net"
    And I press "reset"
    Then I should see "could not be found"
  

  @javascript  
  Scenario: Login after a session timeout
    Given I am logged in as "admin"
    And the entity "Mona Lisa" of kind "Werk/Werke"
    And the session has expired
    When I go to the entity page for "Mona Lisa"
    Then I should not see "Mona Lisa"
    And I should see "Access denied"
    When I follow "login"
    Given the session is not forcibly expired anymore
    When I fill in "username" with "admin"
    And I fill in "password" with "admin"
    And I press "Login"
    And I should see "Mona Lisa"
    Then I should be on the entity page for "Mona Lisa"

  
  Scenario: see credentials without authorization
    Given I am logged in as "john"
    When I go to the credentials page
    Then I should see "Access denied"


  Scenario: create credential without authorization
    Given I am logged in as "john"
    When I send the credential "name:Freaks,description:The KOR-Freaks"
    Then I should see "Access denied"


  Scenario: delete credential without authorization	
    Given I am logged in as "john"
    And the credential "Freaks" described by "The KOR-Freaks"
    When I go to the edit page for "credential" "Freaks"
    Then I should see "Access denied"

    
  Scenario Outline: Direct Actions
    Given I am logged in as "<username>"
    When I send a "<method>" request to "<url>" with params "<params>"
    Then I should get access "<access>"
    
    Examples:
      | username | method | url             | params | access |
      | admin    | GET    | /kinds          |        | yes    |
      | john     | GET    | /kinds          |        | yes    |
      | admin    | GET    | /config/general |        | yes    |
      | john     | GET    | /config/general |        | no     |

  
  @javascript
  Scenario: Don't show group menu when not logged in
    Given the user "guest"
    And I am on the root page
    Then I should not see "Groups"

