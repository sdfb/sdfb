'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:ModalEditPersonCtrl
 * @description
 * # ModalinstanceCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('ModalEditPersonCtrl', ['$scope', '$uibModalInstance', '$timeout', '$window', 'apiService', 'person', function($scope, $uibModalInstance, $timeout, $window, apiService, person) {


    var $ctrl = this;
    console.log(person.data[0]);
    $ctrl.person = person.data[0];
    $ctrl.dateTypes = [{'name':'IN', 'abbr': 'IN'}, {'name': 'CIRCA', 'abbr': 'CA'}, {'name': 'BEFORE', 'abbr': 'BF'}, {'name': 'BEFORE/IN', 'abbr': 'BF/IN'},{'name': 'AFTER', 'abbr': 'AF'}, {'name': 'AFTER/IN', 'abbr': 'AF/IN'}]
    $ctrl.genderTypes = ['male', 'female', 'gender_nonconforming']

    $ctrl.dateTypes.forEach(function(d) {
      if (d.abbr === $ctrl.person.attributes.birth_year_type) {
        $ctrl.person.attributes.birth_year_type = d;
      }
      if (d.abbr === $ctrl.person.attributes.death_year_type) {
        $ctrl.person.attributes.death_year_type = d;
      }
    })

    $ctrl.cancel = function() {
      console.log('dismiss')
      $uibModalInstance.dismiss('cancel');
    };

    $ctrl.close = function() {
      var editPerson = {};
      editPerson.id = $ctrl.person.id;
      editPerson.name = $ctrl.person.attributes.name;
      editPerson.historical_significance = $ctrl.person.attributes.historical_significance;
      editPerson.odnb_id = $ctrl.person.attributes.odnb_id;
      editPerson.gender = $ctrl.person.attributes.gender;
      editPerson.citations = $ctrl.person.attributes.citations;
      editPerson.birthDate = $ctrl.person.attributes.birth_year;
      editPerson.deathDate = $ctrl.person.attributes.death_year;
      editPerson.birthDateType = $ctrl.person.attributes.birth_year_type.abbr;
      editPerson.deathDateType = $ctrl.person.attributes.death_year_type.abbr;
      $uibModalInstance.close(editPerson);
    }

  }]);
