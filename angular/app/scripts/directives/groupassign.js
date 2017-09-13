'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:addNode
 * @description
 * # addNode
 */
angular.module('redesign2017App')
  .directive('groupAssign', function () {
    return {
      templateUrl: './views/group-assign.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        // element.text('this is the groupAssign directive');
				scope.selectedStartDateType = scope.selectedEndDateType = scope.config.dateTypes[1];
      }
    };
  });
