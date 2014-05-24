Feature: relations

  Scenario: create relation
    Given I am logged in as "admin"
    When I go to the relations page
    And I follow "Plus"
    And I fill in "relation[name]" with "loves"
    And I fill in "relation[reverse_name]" with "loves not"
    And I fill in "relation[description]" with "love"
    And I press "Erstellen"
    Then I should see "loves" within "table.kor_table"
    And I should see "loves not" within "table.kor_table"
    And I should see "love" within "table.kor_table"
    And I should see "0" within "table.kor_table"

  Scenario: edit relation
    Given I am logged in as "admin"
    And the relation "loves/is being loved by"
    When I go to the relations page
    And I follow "Pen" within "table.kor_table.relations tr:nth-child(3)"
    And I fill in "relation[name]" with "hates"
    And I fill in "relation[reverse_name]" with "hates not"
    And I fill in "relation[description]" with "hate"
    And I press "Speichern"
    Then I should see "hates"
    And I should see "hates not"
    And I should see "hate"
    And I should not see "loves"
    And I should not see "loves not"
    And I should not see "love"

  @javascript
  Scenario: delete relation
    Given I am logged in as "admin"
    And the relation "loves/is being loved by"
    When I go to the relations page
    And I follow the delete link within the row for "relation" "loves"
    Then I should not see "loves"
