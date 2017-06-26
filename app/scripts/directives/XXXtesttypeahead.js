'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:testTypeahead
 * @description
 * # testTypeahead
 */
angular.module('redesign2017App')
  .directive('testTypeahead', function () {
    return {
      templateUrl: './views/test-typeahead.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        scope.resetPeople = function() {
			    console.log('reset');
			    scope.personSelected = undefined;
			  }
      }
    };
  });
