Feature: Managing Relationship Dates
  Background: Basic seed data exists
    Given required app users exist
    And the "has met" relationship type exists with id 4

  Scenario: Creating a new relationship
    Given Francis Bacon has already been created
    And Anne Bacon has already been created
    When I create a relationship between Anne and Francis
    Then a relationship type is created for the relationship
    And the relationship type has the same start date as the relationship
    And the relationship type has the same end date as the relationship

  Scenario: Updating the dates of a relationship
    Given a relationship exists
    When I change the relationship dates
    Then the relationship type has the same start date as the relationship
    And the relationship type has the same end date as the relationship

  Scenario: Creating a relationship with invalid dates 
    Given Francis Bacon has already been created
    And Anne Bacon has already been created
    When I create a new relationship between 1400 and 1600
    Then the new relationship has an invalid "start_year"

  Scenario: Creating a relationship with invalid dates 
    Given Francis Bacon has already been created
    And Anne Bacon has already been created
    When I create a new relationship between 1550 and 2000
    Then the new relationship has an invalid "end_year"
