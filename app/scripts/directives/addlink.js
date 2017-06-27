'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:addLink
 * @description
 * # addLink
 */
angular.module('redesign2017App')
  .directive('addLink', function () {
    return {
      templateUrl: './views/add-link.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        // element.text('this is the addLink directive');
      }
    };
  });
