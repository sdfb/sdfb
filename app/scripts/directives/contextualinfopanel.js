'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:contextualInfoPanel
 * @description
 * # contextualInfoPanel
 */
angular.module('redesign2017App')
  .directive('contextualInfoPanel', function() {
    return {
      templateUrl: './views/contextual-info-panel.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {

        scope.$on('selectionUpdated', function(event, args) {
          // console.log('selectionUpdated', scope.currentSelection);
          scope.$apply();
        })

        scope.searchODNB = function(id) {
          var url = 'http://www.oxforddnb.com/view/article/{{id}}';
          window.open(url.replace('{{id}}', id), '_blank');
        }

        scope.searchJstor = function(name) {
          var url = 'http://www.jstor.org/action/doBasicSearch?Query={{name}}';
          window.open(url.replace('{{name}}', name.toLowerCase()), '_blank');
        }

        scope.searchGoogle = function(name) {
          var url = 'http://www.google.com/search?q={{name}}';
          window.open(url.replace('{{name}}', name.toLowerCase()), '_blank');
        }

      }
    };
  });
