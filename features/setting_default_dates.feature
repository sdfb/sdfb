Feature: Setting default dates
  Background: Basic seed data exists
    Given required app users exist
    And pre-defined data exists

  Scenario: Adding a person to a group
    Given a person exists
    And a group exists
    And the group started before the person was born
    And the group ended after the person died
    And I do not know when the person joined or departed the group
    When I assign the person to the group
    Then a group membership is created for the person and the group
    And the group membership's start date is the person's birth date
    And the group membership's end date is the person's death date
