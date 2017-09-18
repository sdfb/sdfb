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
        scope.addNode = function(addedNodes, addedNodeID, point, update) {
          scope.newNode.exists = false;

          var newNode = { attributes: { name: scope.newNode.name }, id: addedNodeID, distance: 3, x: point[0], y: point[1]};
          addedNodes.push(newNode);
          addedNodeID += 1;
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
        scope.submitNode = function(addedNodes, update) {
          console.log("node submitted");
          var newNode = angular.copy(scope.newNode);
          if (addedNodes.length > 0 && !addedNodes[addedNodes.length-1].attributes.name) {
            addedNodes[addedNodes.length-1].attributes.name = newNode.name;
            update(scope.data);
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
          } else if (scope.config.contributionMode && args.type === 'relationship') {
            console.log(args);
            d3.select('#source').property('value', args.source.attributes.name);
            d3.select('#target').property('value', args.target.attributes.name)
            // d3.select('#startDate').property('value', Math.max(source.attributes.birth_year, target.attributes.birth_year));
            // d3.select('#startDateType').property('value', 'After/On');
            // d3.select("#endDate").property('value', Math.min(source.attributes.death_year, target.attributes.death_year));
            // d3.select("#endDateType").property('value', 'Before/On');
            // d3.select('#relType').property('value', 'has met');
            scope.addLinkClosed = false;
          }
        })
      }
    };
  }]);
