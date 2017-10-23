'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:contextualInfoPanel
 * @description
 * # contextualInfoPanel
 */
angular.module('redesign2017App')
  .directive('contextualInfoPanel', ['apiService', function(apiService) {
    return {
      templateUrl: './views/contextual-info-panel.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {

        scope.editData = function(id) {
          console.log(id);
        }

        scope.searchODNB = function(id, name) {
          if (id) {
            var url = 'http://www.oxforddnb.com/view/article/{{id}}';
            window.open(url.replace('{{id}}', id), '_blank');
          } else {
            window.alert(name + ' does not have any ODNB ID and it is not possible to query "http://www.oxforddnb.com/" for related information. If you know the ID, please turn on the contribution mode and fill the corresponding record.')
          }
        }

        scope.searchJstor = function(name) {
          var url = 'http://www.jstor.org/action/doBasicSearch?Query={{name}}';
          window.open(url.replace('{{name}}', name.toLowerCase()), '_blank');
        }

        scope.searchGoogle = function(name) {
          var url = 'http://www.google.com/search?q={{name}}';
          window.open(url.replace('{{name}}', name.toLowerCase()), '_blank');
        }

        scope.$watch('currentSelection', function(newValue, oldValue) {
          if (scope.currentSelection.type == 'group') {
            // var groupMembers = [];
            // scope.currentSelection.includes.forEach(function(p) {
            //   console.log(p);
            // });
            console.log(scope.currentSelection.data[0].attributes.people);
            scope.currentSelection.includes.forEach(function(p, i) {
              p.start_year = scope.currentSelection.data[0].attributes.people[i].start_year;
              p.start_year_type = scope.currentSelection.data[0].attributes.people[i].start_year_type;
            })
          }
        })


      }
    };
  }]);
