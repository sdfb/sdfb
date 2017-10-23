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
  controller: ['$scope', '$stateParams', function($scope, $stateParams) {
    $scope.config = {
      contributionMode: false,
      login: {
        status: false,
        user: 'Elizabeth',
      }
    };
	}]
});
