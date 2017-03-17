Feature: Setting default dates
  Background: Basic seed data exists
    Given required app users exist

  Scenario: Adding a person to a group
    Given a person exists
    And a group exists
    And I know when the person joined or departed the group
    When I assign the person to the group
    Then a group membership is created for the person and the group
    And the group membership's start date is the known group assignment start date
    And the group membership's start date type is the known group assignment start date type
    And the group membership's end date is the known group assignment end date
    And the group membership's end date type is the known group assignment end date type

  Scenario: Adding a person to a group
    Given a person exists
    And a group exists
    And the group started before the person was born
    And the group ended after the person died
    And I do not know when the person joined or departed the group
    When I assign the person to the group
    Then a group membership is created for the person and the group
    And the group membership's start date is the person's birth date
    And the group membership's start date type is "AF/IN"
    And the group membership's end date is the person's death date
    And the group membership's end date type is "BF/IN"

  Scenario: Adding a person to a group
    Given a person exists
    And a group exists
    And the group started after the person was born
    And the group ended before the person died
    And I do not know when the person joined or departed the group
    When I assign the person to the group
    Then a group membership is created for the person and the group
    And the group membership's start date is the group's start date
    And the group membership's start date type is "AF/IN"
    And the group membership's end date is the group's end date
    And the group membership's end date type is "BF/IN"

  Scenario: Adding a person to a group
    Given a person exists
    And a group exists
    And the group has an unknown start date
    And the group has an unknown end date
    And the person has an unknown birth date
    And the person has an unknown death date
    And I do not know when the person joined or departed the group
    When I assign the person to the group
    Then a group membership is created for the person and the group
    And the group membership's start date is the Earliest Year
    And the group membership's start date type is "AF/IN"
    And the group membership's end date is the Latest Year
    And the group membership's end date type is "BF/IN"
