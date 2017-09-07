'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:contextualInfoPanel
 * @description
 * # contextualInfoPanel
 */
angular.module('redesign2017App')
  .directive('contextualInfoPanel', function(apiService) {
    return {
      templateUrl: './views/contextual-info-panel.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {

        scope.$on('selectionUpdated', function(event, args) {
          // console.log(event, args);
          if (args.type == 'group') {
            // console.log(args.id)
            var singleGroupUrl = 'http://www.sixdegreesoffrancisbacon.com/groups/{{id}}.json'
            apiService.getFile(singleGroupUrl.replace('{{id}}', args.id)).then(function successCallback(singleGroup) {
              // console.log(singleGroup);
              var allGroups = 'http://www.sixdegreesoffrancisbacon.com/groups.json'
              apiService.getFile(allGroups).then(function successCallback(allGroups) {
                if (allGroups) {
                  scope.currentSelection.groupInfo = allGroups.filter(function(e) {
                    return e.id == singleGroup.id
                  })[0] //filter returns an array, which should have only one element. Store that element in a scope object
                  // console.log(scope.currentSelection.groupInfo);
                }
              });


            }, function errorCallback(singleGroup) {
              console.error("An error occured while fetching file", singleGroup);
            });
          }

          scope.$apply();
        })

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

      }
    };
  });