'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:addGroup
 * @description
 * # addGroup
 */
angular.module('redesign2017App')
  .directive('addGroup', ['apiService', '$window', '$rootScope', function (apiService, $window, $rootScope) {
    return {
      templateUrl: './views/add-group.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        scope.newGroup.startDateType = scope.newGroup.endDateType = scope.config.dateTypes[1];

        scope.addedGroupId = -1;

        scope.groupAlert = function() {
          if (scope.addGroupClosed) {
            $window.alert('To add a group, double-click anywhere on the canvas. To edit a new group, click on the node.');
          } else {
            scope.addGroupClosed = true;
          }
        }

        scope.$watch('noResultsPersonAdd', function(newValue, oldValue) {
          // scope.noResults = newValue;
          if (newValue) {
            scope.newGroup.exists = false;
            scope.notInView = true;
          }
        });

        // When canvas is clicked, add a new circle with dummy data
        scope.addGroupNode = function(addedGroups, point, update) {
          scope.newGroup.exists = false;
          scope.newGroup.id = scope.addedGroupId;

          var x = point[0];
          var y = point[1];

          var newGroup = { attributes: { name: scope.newGroup.name, degree: 5 }, id: scope.addedGroupId, distance: 7, x: x, y: y};
          newGroup.vx = null;
          newGroup.vy = null;
          newGroup.fx = x;
          newGroup.fy = y;
          newGroup.absx = x;
          newGroup.absy = y;
          addedGroups.push(newGroup);
          scope.$apply(function() {
            scope.addGroupClosed = false;
            scope.legendClosed = true;
            scope.newGroup.id = scope.addedGroupId;
            $rootScope.filtersClosed = true;
            scope.addedGroupId -= 1;
          });

          update(scope.data);



        }

        scope.foundNewGroup = function($item) {
          scope.newGroup.exists = true;
          apiService.getGroups($item.id).then(function (result) {
            console.log(result);
            var group = result.data[0];

            scope.newGroup.name = group.attributes.name;
            scope.newGroup.startDate = group.attributes.start_year;
            scope.newGroup.startDateType = group.attributes.start_year_type;
            scope.newGroup.endDate = group.attributes.end_year;
            scope.newGroup.endDateType = group.attributes.end_year_type;
            scope.newGroup.description = group.attributes.description;
            scope.newGroup.id = group.id;
          });
        }

        scope.removeGroup = function(id) {
          console.log(id);
          scope.addedGroups.forEach(function(a, i) {
            if (a.id === id) {
              scope.addedGroups.splice(i,1);
            }
          })
          scope.addToDB.group.forEach(function(a, i) {
            if (a.id === id) {
              scope.addToDB.group.splice(i,1);
            }
          })
          scope.updateNetwork(scope.data);
          scope.newGroup = {};
          scope.newGroup.startDateType = scope.newGroup.endDateType = scope.config.dateTypes[1];
          scope.addGroupClosed = true;

        }

        function checkForNameless(arr) {
          arr.forEach(function(a) {
            if (!a['name']) {
              return true;
            }
          });
        }
        scope.submitGroup = function() {
          console.log("group submitted");
          var newGroup = angular.copy(scope.newGroup);


          scope.addedGroups.forEach(function (a,i) {
            console.log(a.id, scope.newGroup.id);
            if (a.id === scope.newGroup.id) {
              scope.addedGroups[i].attributes = scope.newGroup;
              scope.addedGroups[i].attributes.degree = 5;
              scope.addedGroups[i].id = scope.newGroup.id;
            }
          })
          newGroup = angular.copy(scope.newGroup);
          newGroup.startDateType = newGroup.startDateType.abbr;
          newGroup.endDateType = newGroup.endDateType.abbr;
          // newGroup.created_by = scope.config.userId;
          scope.updateNetwork(scope.data);


          if (!scope.newGroup.exists) { scope.addToDB.group.push(newGroup); }
          scope.addGroupClosed = true;
          scope.newGroup = {};
          console.log(scope.addToDB);
          scope.config.added = true;

        }
      }
    };
  }]);
