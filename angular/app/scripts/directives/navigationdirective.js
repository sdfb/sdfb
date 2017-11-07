'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:navigationDirective
 * @description
 * # navigationDirective
 */
angular.module('redesign2017App')
  .directive('navigationDirective', ['$window', 'apiService', '$cookieStore', function ($window, apiService, $cookieStore) {
    return {
      templateUrl: './views/navigation-directive.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {

        scope.toggleContribute = function() {
          // if (scope.user && scope.user.is_active) {
            scope.config.contributionMode = !scope.config.contributionMode;
            scope.filtersClosed = false;
            if (scope.config.contributionMode) {
              scope.cursorStyle = {'cursor': 'copy'};
            } else {
              scope.cursorStyle = {'cursor': 'auto'};
            }
          // }
          // else {
          //   // $('.login-toggle').dropdown('toggle');
          //   $window.alert("You must log in before you can contribute.")
          //   scope.cursorStyle = {'cursor': 'auto'};
          // }
        }

        var now = new Date()
        scope.today = now.getFullYear() + '_' + (now.getMonth()+1) + '_' + now.getDate();

        scope.logIn = function() {
          apiService.logIn(scope.user).then(function successCallback(result) {
            scope.user = result.data;
            var session = angular.copy(scope.user);
            delete session.contributions;
            delete session.status;
            delete session.error;

            $cookieStore.put('session', session);
          });
        }

        scope.logOut = function() {
          var logOut = {'auth_token': scope.user.auth_token}
          apiService.logOut(logOut).then(function(result) {
            scope.user = {};
            $cookieStore.put('session', null);
          });
        }

      }
    };
  }]);
