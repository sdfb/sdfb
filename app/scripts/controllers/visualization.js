'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:VisualizationCtrl
 * @description
 * # VisualizationCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('VisualizationCtrl', function($scope, $uibModal, $log, $document, apiService, initialConfig, initialData) {
    // console.log(initialConfig,initialData);
    $scope.config = initialConfig;
    $scope.data = initialData;
    $scope.legendClosed = false;
    $scope.filtersClosed = true;
    $scope.peopleFinderClosed = true;

    // Container for data realted to groups
    $scope.groups = {};

    // declare a $scope property where to store the future selections
    $scope.currentSelection = {}

    // $scope.getElementData = function(id, name) {
    //   return apiService.getElementData(id, name);
    // }

    // Other groups modal window
    $scope.modalAnimationsEnabled = true;
    $scope.open = function(size, parentSelector) {
      var parentElem = parentSelector ?
        angular.element($document[0].querySelector('.modal-demo ' + parentSelector)) : undefined;
      var modalInstance = $uibModal.open({
        animation: $scope.modalAnimationsEnabled,
        ariaLabelledBy: 'modal-title',
        ariaDescribedBy: 'modal-body',
        templateUrl: './views/modal-other-groups.html',
        controller: 'ModalinstanceCtrl',
        controllerAs: '$ctrl',
        size: size,
        appendTo: parentElem,
        resolve: {
          groups: function() {
            return $scope.groups.otherGroups;
          },
          currentSelection: function() {
            return $scope.currentSelection;
          }
        }
      });
      modalInstance.result.then(function(selectedItem) {
        $scope.selected = selectedItem;
      }, function() {
        $log.info('Modal dismissed at: ' + new Date());
      });
    };

    // write above
    $scope.$watch('config', function(newValue, oldValue) {
      if (newValue !== oldValue) {
        var config = newValue;
        // $scope.legendClosed = false;
        // $scope.filtersClosed = true; //Stopped filters from automatically closing
        if (config.viewObject == 0 && config.viewMode == 'individual-force') {
          $scope.$broadcast('force layout update');
        } else if (config.viewObject == 0 && config.viewMode == 'individual-concentric') {
          // $scope.$broadcast('force layout update', { data: 'some data' });
        } else if (config.viewObject == 1 && config.viewMode == 'all') {
          console.log('All the groups')
        }
      }
    }, true);
  });
