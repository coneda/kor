Feature: Clipboard
  Scenario: Mass relate
    Given I am logged in as "admin"
    And all entities of kind "Medium/Media" are in the clipboard
    When I go to the clipboard
    And I follow "all"
    And I follow "Relate with"
    Then I should see "Relate with"
    When I select "shows" from "Relation"
    When I follow "recently created"
    And I follow "Mona Lisa"
    And I press "Save"
    When I go to the entity page for "Mona Lisa"
    Then I should see "is shown by"

  Scenario: add to user group
  
  Scenario: Create user groups on the fly
    Given I am logged in as "admin"
    And the user group "Alte Gruppe"
    And I put "Mona Lisa" into the clipboard
    When I go to the clipboard
    And I follow "all"
    And I follow "Add to a global group"
    And I follow "create new"
    And I fill in "Name" with "Neue Gruppe"
    And I press "Save"
    Then I should see "Neue Gruppe has been created"
    When I go to the clipboard
    And I follow "all"
    And I follow "Add to a global group"
    And I select "Neue Gruppe" from "Global group"
    And I press "Save"
    Then I should see "entities have been added to the selected entity group"

  Scenario: Mass relate entities
    Given I am logged in as "admin"
    And the entity "Leonardo" of kind "Person/People" 
    And the entity "Mona Lisa" of kind "Work/Works"
    And the relation "created/was created by" between "Person/People" and "Work/Works"
    And I put "Mona Lisa" into the clipboard
    And I go to the clipboard
    And I follow "all"
    And I follow "Relate with"
    And I select "was created by" from "Relation"
    And I follow "recently created"
    And I follow "Leonardo"
    And I press "Save"
    And I should see "have been related"
    Then "Leonardo" should have "created" "Mona Lisa"

  Scenario: Mass relate entities reversely
    Given I am logged in as "admin"
    And the entity "Leonardo" of kind "Person/People" 
    And the entity "Mona Lisa" of kind "Work/Works"
    And the relation "was created by/created" between "Work/Works" and "Person/People"
    And I put "Leonardo" into the clipboard
    And I go to the clipboard
    And I follow "Relate with"
    Then I should see "You must select at least one entity"
    When I press "Cancel"
    And I follow "all"
    And I follow "Relate with"
    And I select "created" from "Relation"
    And I follow "recently created"
    And I follow "Mona Lisa"
    And I press "Save"
    And I should see "have been related"
    Then "Leonardo" should have "created" "Mona Lisa"

  # TODO: why is this commented out?
  # Scenario: Select entities by kind
  #   Given I am logged in as "admin"
  #   And the kind "Person/People"
  #   And the entity "Mona Lisa" of kind "Work/Works"
  #   And I put "Mona Lisa" into the clipboard
  #   And I go to the clipboard
  #   And I select "Person" from "clipboard_entity_selector"
  #   Then the checkbox should not be checked within the row for "entity" "Mona Lisa"
  #   And I select "Work" from "clipboard_entity_selector"
  #   Then the checkbox should be checked within the row for "entity" "Mona Lisa"
