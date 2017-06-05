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
    // Container for data for groups
    $scope.groups = {};

    console.log($scope.data)
    // declare a $scope property where to store the current selection
    $scope.currentSelection = {}

    $scope.getElementData = function(id,name){
      return apiService.getElementData(id,name);
    }

  	// write above
  	$scope.$watch( 'config', function(newValue, oldValue) {
	    if ( newValue !== oldValue ) {
	      var config = newValue;
        $scope.legendClosed = false;
        console.log($scope.legendClosed)
	      if (config.viewObject == 0 && config.viewMode == 'force') {
	      	$scope.$broadcast('force layout update', {data:'some data'});

	      }
	    }
  	}, true);
  });
