'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:ModalEditUserCtrl
 * @description
 * # ModalinstanceCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('ModalEditUserCtrl', ['$scope', '$uibModalInstance', '$timeout', '$window', 'apiService', '$rootScope', function($scope, $uibModalInstance, $timeout, $window, apiService, $rootScope) {

    var $ctrl = this;

    $ctrl.new = $rootScope.user;

    $ctrl.cancel = function() {
      console.log('dismiss')
      $uibModalInstance.dismiss('cancel');
    };

    $ctrl.close = function() {
      $uibModalInstance.close($ctrl.new);
    }

  }]);
