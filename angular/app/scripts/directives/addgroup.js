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

        scope.watch('noResultsPersonAdd', function(newValue, oldValue) {
          // scope.noResults = newValue;
          if (newValue) {
            scope.newGroup.exists = false;
            scope.notInView = true;
          }
        });

        // When canvas is clicked, add a new circle with dummy data
        scope.addGroupNode = function(addedGroups, point, update) {
          scope.newGroup.exists = false;

          var newGroup = { attributes: { name: scope.newGroup.name, degree: 1 }, id: 0, distance: 7, x: point[0], y: point[1]};
          newGroup.vx = null;
          newGroup.vy = null;
          console.log(newGroup);
          addedGroups.push(newGroup);
          scope.$apply(function() {
            scope.addGroupClosed = false;
            scope.legendClosed = true;
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
            var realNewGroup = { attributes: { name: scope.newGroup.name, degree: 1 }, id: 0, distance: 7, x: scope.singleWidth/2, y: scope.singleHeight/2};
            scope.addedGroups.push(realNewGroup);
          }
          scope.updateNetwork(scope.data);


          if (!scope.newGroup.exists) { scope.addToDB.groups.push(newGroup); }
          scope.addGroupClosed = true;
          scope.newGroup = {};
          console.log(scope.addToDB);

        }
      }
    };
  }]);
