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
  	console.log(initialConfig,initialData);
  	$scope.config = initialConfig;
  	$scope.data = initialData;
  });
