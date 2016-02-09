Feature: Own entities
  As an admin
  In order to have less work while administrating access rules
  I want to allow users to edit their own content
  
  
  Background:
    Given I am logged in as "admin"
    And I go to the users page
    When I follow "Plus"
    And I check "user[make_personal]"
    And I fill in "user[name]" with "harald"
    And I fill in "user[email]" with "harald@gota.com"
    And I press "Create"
    Given the user "harald" has password "harald"

  
  Scenario: Create user with personal collection and check permissions
    Then user "harald" should have the following access rights
      | collection | credential | policy             |
      | harald     | harald     | create             |
      | harald     | harald     | delete             |
      | harald     | harald     | download_originals |
      | harald     | harald     | edit               |
      | harald     | harald     | tagging            |
      | harald     | harald     | view               |
      | harald     | harald     | view_meta          |
      
      
  Scenario: Show a user with a personal_collection
    Then I should see "yes" within the row for "user" "harald"
    When I follow "Pen" within the row for "user" "harald"
    Then I should see element "input[name='user[make_personal]'][checked]"
    
  
  Scenario: Edit a user with a personal collection
    When I follow "Pen" within the row for "user" "harald"
    And I press "Save"
    Then user "harald" should have the following access rights
      | collection | credential | policy             |
      | harald     | harald     | create             |
      | harald     | harald     | delete             |
      | harald     | harald     | download_originals |
      | harald     | harald     | edit               |
      | harald     | harald     | tagging            |
      | harald     | harald     | view               |
      | harald     | harald     | view_meta          |
      
  
  Scenario: Make a user non-personal again
    When I follow "Pen" within the row for "user" "harald"
    And I uncheck "user[make_personal]"
    And I press "Save"
      Then user "harald" should have the following access rights
      | collection | credential | policy |
    When I go to the collections page
    Then I should not see "harald"
    
  
  @javascript
  Scenario: Try to make a user with a non-empty collection non-personal again
    Given the kind "Werk/Werke"
    When I re-login as "harald"
    And I go to the new "Werk-Entity" page
    And I fill in "entity[name]" with "Mona Lisa"
    And press "Create"
    And I re-login as "admin"
    And I go to the users page
    And I follow "Pen" within the row for "user" "harald"
    And I uncheck "user[make_personal]"
    And I press "Save"
    Then I should see "The personal collection could not be deleted because it still contains entities"
  
  
  Scenario: Show an edit link when there are personal collections
    When I go to the collections page
    Then I should see "Edit personal collections"
    When I go to the users page
    And I follow "Pen" within the row for "user" "harald"
    And I uncheck "user[make_personal]"
    And I press "Save"
    And I go to the collections page
    Then I should not see "Edit personal collections"
  
    
  Scenario: Add additional grants for all personal collections
    When I go to the users page
    When I follow "Plus"
    And I check "user[make_personal]"
    And I fill in "user[name]" with "gerhard"
    And I fill in "user[email]" with "gerhard@gota.com"
    And I press "Create"
    
    When I go to the collections page
    And I follow "Edit personal collections"
    And I select "Administrators" from "collection[grants_by_policy][view][]"
    And I unselect "owner" from "collection[grants_by_policy][delete][]"
    And I press "Save"
    Then user "gerhard" should have the following access rights
      | collection | credential | policy             |
      | gerhard    | gerhard    | create             |
      | gerhard    | gerhard    | download_originals |
      | gerhard    | gerhard    | edit               |
      | gerhard    | gerhard    | tagging            |
      | gerhard    | gerhard    | view               |
      | gerhard     | gerhard     | view_meta        |
    Then user "harald" should have the following access rights
      | collection | credential | policy             |
      | harald     | harald     | create             |
      | harald     | harald     | download_originals |
      | harald     | harald     | edit               |
      | harald     | harald     | tagging            |
      | harald     | harald     | view               |
      | harald     | harald     | view_meta          |

    Then user "admin" should have the following access rights
      | collection | credential     | policy             |
      | Default    | Administrators | create             |
      | Default    | Administrators | delete             |
      | Default    | Administrators | download_originals |
      | Default    | Administrators | edit               |
      | Default    | Administrators | tagging            |
      | Default    | Administrators | view               |
      | Default    | Administrators | view_meta          |
      | harald     | Administrators | view               |
      | gerhard    | Administrators | view               |


  @javascript
  Scenario: Apply existing personal collection rights to new personal collections
    When I go to the collections page
    And I follow "Edit personal collections"
    And I select "Administrators" from "collection[grants_by_policy][view][]"
    And I unselect "owner" from "collection[grants_by_policy][delete][]"
    And I press "Save"
    
    When I go to the users page
    When I follow "Plus"
    And I check "user[make_personal]"
    And I fill in "user[name]" with "gerhard"
    And I fill in "user[email]" with "gerhard@gota.com"
    And I press "Create"
  
    Then user "gerhard" should have the following access rights
      | collection | credential | policy             |
      | gerhard    | gerhard    | create             |
      | gerhard    | gerhard    | download_originals |
      | gerhard    | gerhard    | edit               |
      | gerhard    | gerhard    | tagging            |
      | gerhard    | gerhard    | view               |
      | gerhard    | gerhard    | view_meta          |
    Then user "harald" should have the following access rights
      | collection | credential | policy             |
      | harald     | harald     | create             |
      | harald     | harald     | download_originals |
      | harald     | harald     | edit               |
      | harald     | harald     | tagging            |
      | harald     | harald     | view               |
      | harald     | harald     | view_meta          |

    Then user "admin" should have the following access rights
      | collection | credential     | policy             |
      | Default    | Administrators | create             |
      | Default    | Administrators | delete             |
      | Default    | Administrators | download_originals |
      | Default    | Administrators | edit               |
      | Default    | Administrators | tagging            |
      | Default    | Administrators | view               |
      | Default    | Administrators | view_meta          |
      | harald     | Administrators | view               |
      | gerhard    | Administrators | view               |
      

  @javascript      
  Scenario: Change the mail address for a user with a personal collection
    When I go to the users page
    Then I should see "yes" within the row for "user" "harald"
    When I follow "Pen" within the row for "user" "harald"
    And I fill in "user[email]" with "harald@miami.com"
    And I press "Save"
    Then I should see "yes" within the row for "user" "harald"
    