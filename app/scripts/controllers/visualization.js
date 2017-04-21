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
    // declare a $scope property where to store the current selection
    $scope.currentSelection = {}

    // For now, store this data as the clicked person
    // $scope.currentSelection.person1 = $scope.data.included;
    // $scope.currentSelection.person1.birth_year_type = 'in';
    // $scope.currentSelection.person1.death_year_type = 'in';

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
