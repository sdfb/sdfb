Feature: Find person
  Background: Basic seed data exists
    Given required app users exist
    And the "has met" relationship type exists with id 4

  Scenario: Finding a given person with the API
    Given a person exists
    When I access the api endpoint for the person
    And I am given json
    Then the data looks like a list of one person
    And the json is valid JSON-API
    And the data has correct information for the person

  Scenario: Finding multiple people with the API
    Given multiple people exist
    When I access the api endpoint for those people
    And I am given json
    Then the data looks a list containing 2 people
    And the json is valid JSON-API
    And the data has correct ids for those people

  Scenario: Finding the relationships of a person
    Given a relationship exists
    When I access the relationship api endpoint for one of the people in that relationship
    And I am given json
    Then the data includes a list of relationships
    And the json is valid JSON-API
    And the data contains the relationship
    And the data contains references to the people in the relationship

  Scenario: Finding a person with an invalid ID
    When I access the api endpoint for a person with an invalid ID
    And I am given json
    Then the errors include "Invalid person ID(s)"
