'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:addNode
 * @description
 * # addNode
 */
angular.module('redesign2017App')
  .directive('addNode', function () {
    return {
      templateUrl: './views/add-node.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        // element.text('this is the addNode directive');
      }
    };
  });
