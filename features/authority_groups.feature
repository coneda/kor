Feature: authority groups

  Scenario: Authority Groups (no groups, not categories, list)
    Given I am logged in as "admin"
    When I go to the authority groups page
    Then I should see "Verzeichnisse"
    And I should see "Globale Gruppen"
    And I should see no categories nor groups


  Scenario: create authority group
    Given I am logged in as "admin"
    When I go to the authority group categories page
    And I follow "Plus" within ".layout_panel.right.normal_panel_size"
    And I fill in "authority_group[name]" with "Brot"
    And I press "Erstellen"
    Then I should see "Brot wurde angelegt"
    And I should see "Brot" within ".layout_panel.right.normal_panel_size"


  Scenario: edit authority group
    Given I am logged in as "admin"
    And the authority group "Brot"
    When I go to the authority group categories page
    And I follow "Pen" within ".layout_panel.right.normal_panel_size"
    And I fill in "authority_group[name]" with "Wurst"
    And I press "Speichern"
    Then I should see "Wurst wurde abgeändert"
    And I should see "Wurst" within ".layout_panel.right.normal_panel_size"


  @javascript
  Scenario: delete authority group
    Given I am logged in as "admin"
    And the authority group "Brot"
    When I go to the authority group categories page
    And I ignore the next confirmation box
    And I follow "X" within the row for "authority_group" "Brot"
    Then I should be on the authority group categories page
    Then I should not see "Brot" within ".layout_panel.right.normal_panel_size"


  Scenario: create authority group category
    Given I am logged in as "admin"
    When I go to the authority group categories page
    And I follow "Plus" within ".layout_panel.left.small_panel_size"
    And I fill in "authority_group_category[name]" with "Frühstück"
    And I press "Erstellen"
    Then I should see "Frühstück wurde angelegt"
    And I should see "Frühstück" within ".layout_panel.left.small_panel_size"


  Scenario: edit authority group category
    Given I am logged in as "admin"
    And the authority group category "Frühstück"
    When I go to the authority group categories page
    And I follow "Pen" within ".layout_panel.left.small_panel_size"
    And I fill in "authority_group_category[name]" with "Mittachmahl"
    And I press "Speichern"
    Then I should see "Mittachmahl wurde abgeändert"
    And I should see "Mittachmahl" within ".layout_panel.left.small_panel_size"


  @javascript
  Scenario: delete authority group category
    Given I am logged in as "admin"
    And the authority group category "Frühstück"
    When I go to the authority group categories page
    And I ignore the next confirmation box
    And I follow "X" within the row for "authority_group_category" "Frühstück"
    Then I should not see "Frühstück" within ".layout_panel.left.small_panel_size"
    And I should be on the authority group categories page


  Scenario: create deep authority group category
    Given I am logged in as "admin"
    When I go to the authority group categories page
    And I follow "Plus" within ".layout_panel.left.small_panel_size"
    And I fill in "authority_group_category[name]" with "Level 1"
    And I press "Erstellen"
    And I follow "Level 1" within ".layout_panel.left .kor_table"
    Then I should see "obere Ebene » Level 1" within ".type.subtitle"
    When I follow "Plus" within ".layout_panel.left.small_panel_size"
    And I fill in "authority_group_category[name]" with "Level 2"
    And I press "Erstellen"
    And I follow "Level 2" within ".layout_panel.left .kor_table"
    Then I should see "obere Ebene » Level 1 » Level 2" within ".type.subtitle"


  @javascript
  Scenario: delete deep authority group category
    Given I am logged in as "admin"
    And the authority group categories structure "obere Ebene >> Level 1 >> Level 2"
    When I go to the authority group categories page
    And I ignore the next confirmation box
    And I follow "X" within the row for "authority_group_category" "obere Ebene"
    Then I should not see "Level 1" within ".layout_panel.left"
    And I should not see "Level 2" within ".layout_panel.left"


  @javascript
  Scenario: delete authority group category with deep authority group
    Given I am logged in as "admin"
    And the authority group category "Level 1"
    And the authority group "Level 1 Group" inside "Level 1"
    When I go to the authority group categories page
    And I ignore the next confirmation box
    And I follow "X" within the row for "authority_group_category" "Level 1 "
    Then I should not see "Level 1" within ".layout_panel.left.small_panel_size"
    And I should not see "Level 1 Group" within ".layout_panel.right.normal_panel_size"


  Scenario: move authority group
    Given I am logged in as "admin"
    And the authority group category "Frühstück"
    And the authority group category "Mittachmahl"
    And the authority group "Brot" inside "Frühstück"
    When I go to the authority group categories page
    And I follow "Frühstück" within ".layout_panel.left.small_panel_size"
    And I follow "Arrows_right" within ".layout_panel.right.normal_panel_size"
    And I select "Mittachmahl" from "authority_group[authority_group_category_id]"
    And I press "Senden"
    Then I should see "Brot wurde abgeändert"
    And I should see "Brot" within ".layout_panel.right.normal_panel_size"
    And I should see "obere Ebene » Mittachmahl" within ".type.subtitle"

    
  Scenario: download zip file
    Given I am logged in as "admin"
    And the authority group "Natur"
    And the authority group "Natur" contains a medium
    When I go to the authority group page for "Natur"
    And I follow "Zip"
    When I go to the authority group page for "Natur"
    Then I should be on the authority group page for "Natur"
    
    
  Scenario: Authority Groups (no, groups, no categories, create both)
    Given I am logged in as "admin"
    Given I am on the authority groups page
    When I follow "new_category"
    And I fill in "authority_group_category[name]" with "Test Category"
    And I press "Erstellen"
    Then I should be on the authority groups page
    And I should see "Test Category"
    When I follow "Test Category"
    Then I should be on the authority group category page for "Test Category"
    When I follow "new_group"
    And I fill in "authority_group[name]" with "Test Authority Group"
    And I press "Erstellen"
    Then I should be on the authority group category page for "Test Category"
    And I should see "Test Authority Group"
    
  
