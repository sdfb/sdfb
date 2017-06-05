'use strict';

/**
 * @ngdoc function
 * @name redesign2017App.controller:VisualizationCtrl
 * @description
 * # VisualizationCtrl
 * Controller of the redesign2017App
 */
angular.module('redesign2017App')
  .controller('VisualizationCtrl', function ($scope, apiService,initialConfig, initialData) {
    // console.log(initialConfig,initialData);
    $scope.config = initialConfig;
    $scope.data = initialData;

    // Container for data realted to groups
    $scope.groups = {};

    // declare a $scope property where to store the future selections
    $scope.currentSelection = {}

    $scope.getElementData = function(id,name){
      return apiService.getElementData(id,name);
    }

    // $scope.$on('selectionUpdated', function(event, args){
    //   $scope.$broadcast('selectionUpdated', args);
    // })

    // write above
    $scope.$watch( 'config', function(newValue, oldValue) {
      if ( newValue !== oldValue ) {
        var config = newValue;
        $scope.legendClosed = false;
        $scope.filtersClosed = true;
        if (config.viewObject == 0 && config.viewMode == 'force') {
          $scope.$broadcast('force layout update', {data:'some data'});
        }
      }
    }, true);
  });