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
      var editGroup = {};
      editGroup.id = parseInt($ctrl.group.id);
      editGroup.name = $ctrl.group.attributes.name;
      editGroup.description = $ctrl.group.attributes.description;
      editGroup.citations = $ctrl.group.attributes.citations;
      editGroup.startDate = $ctrl.group.attributes.start_year;
      editGroup.endDate = $ctrl.group.attributes.end_year;
      editGroup.startDateType = $ctrl.group.attributes.start_year_type.abbr;
      editGroup.endDateType = $ctrl.group.attributes.end_year_type.abbr;
      if ($ctrl.group.is_dismissed) {
        editGroup.is_active = !$ctrl.group.is_dismissed;
      }
      $uibModalInstance.close(editGroup);
    }

  }]);
