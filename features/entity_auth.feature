Feature: Entity authentorization
  # functionality dropped
  # Scenario: Show the select as current link for viewable entities because he has edit rights in another collection
  #   And user "joe" is allowed to "view/edit" collection "side" through credential "side_editors"
  #   And user "joe" is allowed to "view" collection "main" through credential "main_viewers"
  #   And the entity "Mona Lisa" of kind "Werk/Werke" inside collection "main"
  #   When I go to the entity page for "Mona Lisa"
  #   And I debug
  #   Then I should see element "a[kor-to-current]"

  Scenario: show (jdoe)
    Given I am logged in as "jdoe"
    When I go to the entity page for "The Last Supper"
    Then I should see "Access denied"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Mona Lisa"
    And I should not see link "edit"
    And I should not see link "delete"

  Scenario: show (mrossi)
    Given I am logged in as "mrossi"
    When I go to the entity page for "The Last Supper"
    Then I should see "The Last Supper"
    And I should see link "edit"
    And I should see link "delete"

  Scenario: don't show relationships (jdoe)
    Given I am logged in as "jdoe"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Leonardo"
    And I should see "Louvre"
    And I should not see "The Last Supper"
    And I should not see "is related to"

  Scenario: show relationships (mrossi)
    Given I am logged in as "mrossi"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Leonardo"
    And I should see "Louvre"
    And I should see "The Last Supper"
    And I should see "is related to"  
    
  Scenario: 'add relationship' button (jdoe)
    Given I am logged in as "jdoe"
    When I go to the entity page for "Mona Lisa"
    Then I should not see link "add relationship"

  Scenario: 'add relationship' button (mrossi)
    Given I am logged in as "mrossi"
    When I go to the entity page for "Mona Lisa"
    Then I should see link "add relationship"

  Scenario: show edit and delete buttons for relationships (jdoe)
    Given I am logged in as "jdoe"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Leonardo"
    Then I should not see "edit relationship"
    Then I should not see "delete relationship"

  Scenario: show edit and delete buttons for relationships (mrossi)
    Given I am logged in as "mrossi"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Leonardo"
    Then I should not see "edit relationship" within "[name='is related to']"
    Then I should not see "delete relationship" within "[name='is related to']"
    
  Scenario: Show media previews for authorized media entities
    Given entity "The Last Supper" is in collection "default"
    And I am logged in as "jdoe"
    When I go to the entity page for "Mona Lisa"
    Then I should not see link "expand" within "[name='is related to']"
    When I follow "The Last Supper"
    Then I should see link "expand" within "[name='is related to']"

  Scenario: Show master data (jdoe)
    Given I am logged in as "jdoe"
    When I go to the entity page for "Mona Lisa"
    Then I should not see "Master data"

  Scenario: Show master data (mrossi)
    Given I am logged in as "mrossi"
    When I go to the entity page for "The Last Supper"
    Then I should see "Master data"
