Feature: Find person
  Background: Basic seed data exists
    Given required app users exist
    And the "has met" relationship type exists with id 4

  Scenario: Finding a given person with the API
    Given a person exists
    When I access the api endpoint for the person
    Then I am given json that looks a person
    And the json has correct information for the person

  Scenario: Finding multiple people with the API
    Given multiple people exist
    When I access the api endpoint for those people
    Then I am given json that looks a list containing 2 people
    And the json has correct ids for those people

  Scenario: Finding the relationships of a person
    Given a relationship exists
    When I access the relationship api endpoint for one of the people in that relationship
    Then I am given json that includes a list of relationships
    And the json contains the relationship

  Scenario: Finding a person with an invalid ID
    When I access the api endpoint for a person with an invalid ID
    Then I am given a json error telling me "Invalid person ID(s)"
