Feature: tagging
  Scenario: Hide inplace controls without relevant rights
    Given user "guest" is allowed to "view" collection "default" via credential "guests"
    When I go to the entity page for "Mona Lisa"
    Then I should not see element "a[title='edit tags']"

  Scenario: Show inplace controls given the user has the rights
    Given user "guest" is allowed to "view/tagging" collection "default" via credential "guests"
    When I go to the entity page for "Mona Lisa"
    Then I should see element "a[title='edit tags']"

  Scenario: Use inplace controls
    Given I am logged in as "admin"
    And I go to the entity page for "Mona Lisa"
    When I follow "edit tags"
    Then I should see element "kor-inplace-tags input"
    When I fill in "tags" with "smile, woman, 2d"
    And I press "Save" within "kor-inplace-tags"
    Then I should see "Tags: art, late, smile, woman, 2d"
    When I go to the entity page for "Mona Lisa"
    Then I should see "Tags: art, late, smile, woman, 2d"
    When I go to the edit page for "entity" "Mona Lisa"
    Then field "Tags" should have value "art, late, smile, woman, 2d"
