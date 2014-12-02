Feature: Navigation Menu

  @javascript
  Scenario: User Menu
    Given I am logged in as "john"
    And "Gruppen" is expanded
    Then I should see "Einfache Suche" within "#menu"
    And I should see "Expertensuche" within "#menu"
    And I should see "Neue Einträge" within "#menu"
    And I should see "Zwischenablage" within "#menu"
    And I should see "Gruppen" within "#menu"
    And I should see "Globale" within "#menu"
    And I should see "Eigene" within "#menu"
    And I should see "Veröffentlichte" within "#menu"
    And I should see "Profil bearbeiten" within "#menu"
    And I should see "Statistiken" within "#menu"
    And I should not see "Administration" within "#menu"
    And I should not see option "Entität anlegen" within "#menu"
    And I should not see "Ungültige Entitäten" within "#menu"
    And I should not see "Neue Entitäten" within "#menu"
    

  @javascript
  Scenario: Admin Menu
    Given I am logged in as "admin"
    And "Gruppen" is expanded
    And "Administration" is expanded
    Then I should see "Einfache Suche" within "#menu"
    And I should see "Expertensuche" within "#menu"
    And I should see "Neue Einträge" within "#menu"
    And I should see "Zwischenablage" within "#menu"
    And I should see "Gruppen" within "#menu"
    And I should see "Globale" within "#menu"
    And I should see "Eigene" within "#menu"
    And I should see "Veröffentlichte" within "#menu"
    And I should see option "Entität anlegen"
    And I should see "Administration" within "#menu"
    And I should see "Allgemein" within "#menu"
    And I should see "Relationen" within "#menu"
    And I should see "Entitätstypen" within "#menu"
    And I should see "Sammlungen" within "#menu"
    And I should see "Benutzergruppen" within "#menu"
    And I should see "Benutzerverwaltung" within "#menu"
    And I should see "Profil bearbeiten" within "#menu"
    And I should see "Statistiken" within "#menu"
    And I should see option "Entität anlegen" within "#menu"
    And I should see "Ungültige Entitäten" within "#menu"
    And I should see "Neue Entitäten" within "#menu"

    
  @javascript
  Scenario: User menu as a user_admin but not credential_admin
    Given the user "john" is a "user_admin"
    And I am logged in as "john"
    And "Administration" is expanded
    Then I should see "Benutzerverwaltung" within "#menu"
    And I should not see "Benutzergruppen" within "#menu"
    
  
  @javascript
  Scenario: Toggle groups menu as a admin
    Given I am logged in as "admin"
    When I go to the home page
    And I follow "Gruppen"
    Then I should really see element "#group_links"
    When I follow "Gruppen"
    Then I should not really see element "#group_links"
    
    
  @javascript
  Scenario: No admin rights => no config menu
    Given the user "john"
    And I am logged in as "john"
    When I go to the root page
    Then I should not see "Administration"
    
