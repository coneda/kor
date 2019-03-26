Feature: profile
  Scenario: change locale
    Given I am logged in as "admin"
    And I follow "Edit profile"
    And I select "de" from "Language"
    And I press "Save"
    Then I should see "Hochladen" within widget "kor-menu"