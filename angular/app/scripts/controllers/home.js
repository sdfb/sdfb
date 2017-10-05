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
  controller: ['$scope', function($scope) {
    $scope.config = {contributionMode: false};
    // $scope.config.contributionMode = false;
	}]
});
