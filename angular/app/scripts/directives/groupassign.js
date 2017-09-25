'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:addNode
 * @description
 * # addNode
 */
angular.module('redesign2017App')
  .directive('groupAssign', function () {
    return {
      templateUrl: './views/group-assign.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        // element.text('this is the groupAssign directive');
				scope.groupAssign.startDateType = scope.groupAssign.endDateType = scope.config.dateTypes[1];

        scope.showGroupAssign = function(d) {
          d3.selectAll(".group").on('mouseenter', function(g) {
            scope.$apply(function() {
              scope.groupAssign.person.name = d.attributes.name;
              scope.groupAssign.person.id = d.id;
              scope.groupAssign.group.name = g.name;
              scope.groupAssign.group.id = g.groupId;
              scope.groupAssignClosed = false;
            });
          })
          .on('mouseleave', function(g) {
            scope.$apply(function() {
              scope.groupAssignClosed = true;
            });
          });
        }

        scope.endGroupEvents = function() {
          d3.selectAll(".group").on("mouseenter", null);
          d3.selectAll(".group").on("mouseleave", null);
        }

        scope.submitGroupAssign = function() {
          console.log("node submitted");
          // var newNode = {attributes: {name: scope.person.added, birthdate: d3.select('#birthDate').node().value, deathdate: d3.select('#deathDate').node().value, title: d3.select('#title').node().value, suffix: d3.select('#suffix').node().value, alternate_names: d3.select('#alternates').node().value},  notes: d3.select('#alternates').node().value, id: addedNodeID}
          var newGroupAssign = angular.copy(scope.groupAssign);
          scope.addToDB.group_assignments.push(newGroupAssign);
          console.log(scope.addToDB);
          scope.groupAssignClosed = true;

        }
      }
    };
  });
