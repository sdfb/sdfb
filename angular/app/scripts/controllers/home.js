'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:HomeCtrl
 * @description
 * # VisualizationCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App').component('home', {
  // bindings: { networkData: '<' },
  templateUrl: 'views/home.html',
  controller: ['$scope', '$stateParams', '$uibModal', '$log', function($scope, $stateParams, $uibModal, $log) {
    $scope.config = {
      contributionMode: false,
      layout: 'individual-force',
      login: {
        status: false,
        user: 'Elizabeth',
      }
    };

    $scope.openCurate = function(size, parentSelector) {
      var parentElem = parentSelector ?
        angular.element($document[0].querySelector('.modal-demo ' + parentSelector)) : undefined;
      var modalInstance = $uibModal.open({
        animation: $scope.modalAnimationsEnabled,
        ariaLabelledBy: 'modal-curate',
        ariaDescribedBy: 'modal-curate-body',
        templateUrl: './views/modal-curate.html',
        controller: 'ModalCurateCtrl',
        controllerAs: '$ctrl',
        size: size,
        appendTo: parentElem,
        resolve: {
          addToDB: function() {
            return $scope.addToDB;
          }
        }
      });
      modalInstance.result.then(function(result) {
      }, function() {
        $log.info('Modal dismissed at: ' + new Date());
      });
    };

	}]
});
