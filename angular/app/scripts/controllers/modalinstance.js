'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:ModalinstanceCtrl
 * @description
 * # ModalinstanceCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('ModalinstanceCtrl', ['$scope', '$uibModalInstance', 'groups', 'currentSelection', function($scope, $uibModalInstance, groups, currentSelection) {

    console.log('currentSelection', currentSelection);
    console.log('groups', groups);

    if (currentSelection.attributes) {
      currentSelection.attributes.groups.forEach(function(selectedGroup) {
        // console.log(selectedGroup);
        groups.forEach(function(group) {
          // console.log(group);
          if (selectedGroup == group.groupId) {
            group.active = true;
          }
        })
      });
    }

    var $ctrl = this;
    $ctrl.groups = groups;

    // Pre-selection
    $ctrl.selected = {
      group: $ctrl.groups[0]
    };

    $ctrl.ok = function() {
      $uibModalInstance.close($ctrl.selected.group);
    };

    $ctrl.cancel = function() {
      console.log('dismiss')
      $uibModalInstance.dismiss('cancel');
    };

  }]);
