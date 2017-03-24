Feature: Deleting Unapproved Relationship Type Assignment
  Background: Basic seed data exists
    Given required app users exist
    And a curator user exists
    And the "has met" relationship type exists with id 4
    And the "has eaten" relationship type exists with id 99

  Scenario: Creating an unapproved relationship as a curator
    Given a relationship exists
    And there is unapproved relationship of type "has eaten"
    Then the "has eaten" relationship should exist


  Scenario: Deleting an unapproved relationship as a curator
    Given a relationship exists
    And there is unapproved relationship of type "has eaten"
    Then the curator can delete the "has eaten" relationship

  Scenario: Rujecting an unapproved relationship as a curator
    Given a relationship exists
    And there is unapproved relationship of type "has eaten"
    Then the curator can reject the "has eaten" relationship
    And  it is possible to reject the "has eaten" relationship