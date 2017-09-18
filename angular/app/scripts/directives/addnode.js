'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:addNode
 * @description
 * # addNode
 */
angular.module('redesign2017App')
  .directive('addNode', ['apiService', function (apiService) {
    return {
      templateUrl: './views/add-node.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        // element.text('this is the addNode directive');
        scope.newNode.birthDateType = scope.newNode.deathDateType = scope.config.dateTypes[1];

        // When canvas is clicked, add a new circle with dummy data
        scope.addNode = function(addedNodes, point, update) {
          scope.newNode.exists = false;

          var newNode = { attributes: { name: scope.newNode.name }, id: 0, distance: 7, x: point[0], y: point[1]};
          addedNodes.push(newNode);
          scope.$apply(function() {
            scope.addNodeClosed = false;
            scope.legendClosed = true;
          });

          update(scope.data);


        }

        scope.foundPerson = function($item) {
          scope.newNode.exists = true;
          apiService.getPeople($item.id).then(function (result) {
            var person = result.data[0];
            scope.newNode.name = person.attributes.name;
            scope.newNode.birthDate = person.attributes.birth_year;
            scope.newNode.birthDateType = person.attributes.birth_year_type;
            scope.newNode.deathDate = person.attributes.death_year;
            scope.newNode.deathDateType = person.attributes.death_year_type;

          });
        }
        scope.submitNode = function() {
          console.log("node submitted");
          var newNode = angular.copy(scope.newNode);

          if (scope.config.viewMode === 'individual-force' ||  scope.config.viewMode === 'individual-concentric') {
            if (scope.addedNodes.length > 0 && !scope.addedNodes[scope.addedNodes.length-1].attributes.name) {
              scope.addedNodes[scope.addedNodes.length-1].attributes.name = newNode.name;
            }
            scope.updatePersonNetwork(scope.data);
          } else if (scope.config.viewMode === 'shared-network') {
            if (scope.addedSharedNodes.length > 0 && !scope.addedSharedNodes[scope.addedSharedNodes.length-1].attributes.name) {
              scope.addedSharedNodes[scope.addedSharedNodes.length-1].attributes.name = newNode.name;
            }
            scope.updateSharedNetwork(scope.data);
          }

          scope.addToDB.nodes.push(newNode);
          scope.addNodeClosed = true;
          scope.newNode.name = null;
          console.log(scope.addToDB);

        }

        scope.$on('selectionUpdated', function(event, args) {
          if (scope.config.contributionMode && args.type === 'person') {
            console.log(args);
            scope.newNode.name = args.attributes.name;
            scope.newNode.birthDate = args.attributes.birth_year;
            scope.newNode.birthDateType = args.attributes.birth_year_type;
            scope.newNode.deathDate = args.attributes.death_year;
            scope.newNode.deathDateType = args.attributes.death_year_type;
            scope.newNode.exists = true;
            scope.addNodeClosed = false;
          }
        });
      }
    };
  }]);
