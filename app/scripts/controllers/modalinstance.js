'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:ModalinstanceCtrl
 * @description
 * # ModalinstanceCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('ModalinstanceCtrl', function($uibModalInstance, groups) {
    var $ctrl = this;
    $ctrl.groups = groups;
    $ctrl.selected = {
      item: $ctrl.groups[0]
    };

    $ctrl.ok = function() {
      $uibModalInstance.close($ctrl.selected.group);
    };

    $ctrl.cancel = function() {
    	console.log('dismiss')
      $uibModalInstance.dismiss('cancel');
    };
  });
