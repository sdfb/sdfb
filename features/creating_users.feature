Feature: Creating Users
  Background: Basic seed data exists
    Given required app users exist
    And pre-defined data exists

  Scenario: Creating Francis Bacon
    When I create Francis Bacon with his known ID
    Then Francis Bacon is persisted

  Scenario: Creating a relationship
    Given Francis Bacon has already been created
    And Anne Bacon has already been created
    When I create a relationship between Anne and Francis
    Then the relationship is persisted
