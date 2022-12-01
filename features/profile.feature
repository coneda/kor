Feature: profile
  Scenario: change locale
    Given I am logged in as "admin"
    And I follow "Edit profile"
    Then field "Language" should have value "en"
    And I select "de" from "Language"
    And I press "Save"
    Then I should see "has been changed"
    Then I should see "Hochladen" within widget "kor-menu"

  Scenario: change password
    Given I am logged in as "jdoe"
    And I follow "Edit profile"
    And I fill in "Password" with "mypass"
    And I fill in "Repeat password" with "mypass"
    And I press "Save"
    Then I should see "has been changed"
    Then user "jdoe" should have password "mypass"
    