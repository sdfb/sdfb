'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:addNode
 * @description
 * # addNode
 */
angular.module('redesign2017App')
  .directive('addGroup', ['apiService', function (apiService) {
    return {
      templateUrl: './views/add-group.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        // element.text('this is the addNode directive');
        scope.newGroup.startDateType = scope.newGroup.endDateType = scope.config.dateTypes[1];

        scope.addedGroupId = -1;

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

          var x = scope.singleWidth*(3/4)+(scope.addedGroupId)*20;
          var y = scope.singleHeight*(3/4)+(scope.addedGroupId)*20;

          var newGroup = { attributes: { name: scope.newGroup.name, degree: 5 }, id: scope.addedGroupId, distance: 7, x: x, y: y};
          newGroup.vx = null;
          newGroup.vy = null;
          newGroup.fx = x;
          newGroup.fy = y;
          addedGroups.push(newGroup);
          scope.$apply(function() {
            scope.addGroupClosed = false;
            scope.legendClosed = true;
            scope.newGroup.id = scope.addedGroupId;
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
          });
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


          if (scope.addedGroups.length > 0 && !scope.addedGroups[scope.addedGroups.length-1].attributes.name) {
            scope.addedGroups[scope.addedGroups.length-1].attributes.name = newGroup.name;
          }
          else if (scope.addedGroups.length === 0 || !checkForNameless(scope.addedGroups)) {
            var x = scope.singleWidth*(3/4)+(scope.addedGroupId)*20;
            var y = scope.singleHeight*(3/4)+(scope.addedGroupId)*20;
            var realNewGroup = { attributes: { name: scope.newGroup.name, degree: 5 }, id: scope.addedGroupId, distance: 7, x: x, y: y};
            realnewGroup.vx = null;
            realnewGroup.vy = null;
            realnewGroup.fx = x;
            realnewGroup.fy = y;
            scope.addedGroups.push(realNewGroup);
          }
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
