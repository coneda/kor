Feature: Show media in the gallery and show certain related entities
  Scenario: View an empty gallery
    When I go to the gallery
    Then I should see "No entities found"

  Scenario: view the gallery (jdoe)
    Given I am logged in as "jdoe"
    When I go to the gallery
    Then I should see "New entries"
    And I should see "Leonardo"
    And I should see "Mona Lisa"
    And I should not see "The Last Supper"

  Scenario: view the gallery (mrossi)
    Given I am logged in as "mrossi"
    When I go to the gallery
    Then I should see "New entries"
    And I should see "Leonardo"
    And I should see "Mona Lisa"
    And I should see "The Last Supper"
    
  Scenario: view gallery when no secondary relationships exist
    Given entity "Leonardo" is in collection "private"
    Given I am logged in as "jdoe"
    When I go to the gallery
    And I should not see "Leonardo"
    And I should see "Mona Lisa"
    And I should not see "The Last Supper"

  Scenario: secondary relationship refers back to the medium
    Given the secondary relationship refers back to the medium
    Given I am logged in as "admin"
    When I go to the gallery
    Then I should see "2" gallery items
    And I should see "medium 6" within gallery item "1"
    And I should see "medium 7" within gallery item "1"
    And I should see "Mona Lisa (the real one)" within gallery item "1"
    And I should see "The Last Supper" within gallery item "1"
    And I should see "medium 6" within gallery item "2"
    And I should see "medium 7" within gallery item "2"
    And I should see "Mona Lisa (the real one)" within gallery item "2"
    And I should not see "The Last Supper" within gallery item "2"
