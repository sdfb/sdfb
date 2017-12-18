'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:ModalEditGroupCtrl
 * @description
 * # ModalinstanceCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('ModalEditGroupCtrl', ['$scope', '$uibModalInstance', '$timeout', '$window', 'apiService', 'group', function($scope, $uibModalInstance, $timeout, $window, apiService, group) {


    var $ctrl = this;
    $ctrl.group = group.data.data[0];
    $ctrl.dateTypes = [{'name':'IN', 'abbr': 'IN'}, {'name': 'CIRCA', 'abbr': 'CA'}, {'name': 'BEFORE', 'abbr': 'BF'}, {'name': 'BEFORE/IN', 'abbr': 'BF/IN'},{'name': 'AFTER', 'abbr': 'AF'}, {'name': 'AFTER/IN', 'abbr': 'AF/IN'}]
    $ctrl.genderTypes = ['male', 'female', 'gender_nonconforming']

    $ctrl.dateTypes.forEach(function(d) {
      if (d.abbr === $ctrl.group.attributes.start_year_type) {
        $ctrl.group.attributes.start_year_type = d;
      }
      if (d.abbr === $ctrl.group.attributes.end_year_type) {
        $ctrl.group.attributes.end_year_type = d;
      }
    })

    $ctrl.cancel = function() {
      console.log('dismiss')
      $uibModalInstance.dismiss('cancel');
    };

    $ctrl.close = function() {
      var editPerson = {};
      editPerson.id = $ctrl.group.id;
      editPerson.name = $ctrl.group.attributes.name;
      editPerson.historical_significance = $ctrl.group.attributes.historical_significance;
      editPerson.odnb_id = $ctrl.group.attributes.odnb_id;
      editPerson.gender = $ctrl.group.attributes.gender;
      editPerson.citations = $ctrl.group.attributes.citations;
      editPerson.alternates = $ctrl.group.attributes.alternates;
      editPerson.prefix = $ctrl.group.attributes.prefix;
      editPerson.title = $ctrl.group.attributes.title;
      editPerson.suffix = $ctrl.group.attributes.suffix;
      editPerson.birthDate = $ctrl.group.attributes.birth_year;
      editPerson.deathDate = $ctrl.group.attributes.death_year;
      editPerson.birthDateType = $ctrl.group.attributes.birth_year_type.abbr;
      editPerson.deathDateType = $ctrl.group.attributes.death_year_type.abbr;
      if ($ctrl.group.is_dismissed) {
        editPerson.is_active = !$ctrl.group.is_dismissed;
      }
      $uibModalInstance.close(editPerson);
    }

  }]);
