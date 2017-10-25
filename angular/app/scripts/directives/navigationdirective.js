'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:navigationDirective
 * @description
 * # navigationDirective
 */
angular.module('redesign2017App')
  .directive('navigationDirective', function () {
    return {
      templateUrl: './views/navigation-directive.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {

        scope.toggleContribute = function() {
          if (scope.config.login.status === true) {
            scope.config.contributionMode = !scope.config.contributionMode;
            if (scope.config.contributionMode) {
              scope.cursorStyle = {'cursor': 'copy'};
            } else {
              scope.cursorStyle = {'cursor': 'auto'};
            }
          }
          else {
            $('.login-toggle').dropdown('toggle');
            scope.cursorStyle = {'cursor': 'auto'};
          }
        }

        var now = new Date()
        scope.today = now.getFullYear() + '_' + (now.getMonth()+1) + '_' + now.getDate();

      }
    };
  });
