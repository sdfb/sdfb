'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:ModalReviewCtrl
 * @description
 * # ModalinstanceCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('ModalReviewCtrl', ['$scope', '$uibModalInstance', '$timeout', 'addToDB', '$window', 'apiService', '$rootScope', function($scope, $uibModalInstance, $timeout, addToDB, $window, apiService, $rootScope) {

    var $ctrl = this;
    $ctrl.addToDB = addToDB;
    // $ctrl.sendData = sendData;

    $ctrl.remove = function(index, list) {
      list.splice(index,1);
    };

    $ctrl.ok = function() {
      $uibModalInstance.close($ctrl.selected.group);
    };

    $ctrl.cancel = function() {
      console.log('dismiss')
      $uibModalInstance.dismiss('cancel');
    };

    $ctrl.close = function() {
      $ctrl.addToDB.auth_token = $rootScope.user.auth_token;
      console.log(JSON.stringify($ctrl.addToDB));
      $uibModalInstance.close($ctrl.addToDB);
    }

  }]);
