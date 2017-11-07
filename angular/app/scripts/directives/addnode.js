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

        scope.addedNodeId = 0;

        scope.$watch('noResultsPersonAdd', function(newValue, oldValue) {
          // scope.noResults = newValue;
          if (newValue) {
            scope.newNode.exists = false;
            scope.notInView = true;
          }
        });

        // When canvas is clicked, add a new circle with dummy data
        scope.addNode = function(addedNodes, point, update) {
          console.log(scope.data);

          scope.newNode.exists = false;

          var x = scope.singleWidth*(3/4)+scope.addedNodeId*20;
          var y = scope.singleHeight*(3/4)+scope.addedNodeId*20;

          var newNode = { attributes: { name: scope.newNode.name, degree: 1 }, id: scope.addedNodeId, distance: 7, x: x, y: y};
          newNode.vx = null;
          newNode.vy = null;
          newNode.fx = x;
          newNode.fy = y;
          console.log(newNode);
          addedNodes.push(newNode);
          scope.$apply(function() {
            scope.addNodeClosed = false;
            scope.legendClosed = true;
            scope.newNode.id = scope.addedNodeId;
            scope.addedNodeId += 1;
          });
          update(scope.data);



        }

        scope.foundPerson = function($item) {
          scope.newNode.exists = true;
          apiService.getPeople($item.id).then(function (result) {
            var person = result.data[0];
            scope.newNode.name = person.attributes.name;
            scope.newNode.birthDate = person.attributes.birth_year;
            scope.newNode.birthDateType = scope.config.dateTypes.filter(function(d) { return person.attributes.birth_year_type === d.abbr; })[0];
            scope.newNode.deathDate = person.attributes.death_year;
            scope.newNode.deathDateType = scope.config.dateTypes.filter(function(d) { return person.attributes.death_year_type === d.abbr; })[0];
            scope.newNode.historical_significance = person.attributes.historical_significance;
            scope.newNode.id = person.id;
          });
          var ids_in_view = {};
          d3.selectAll('.node').each(function(d) { ids_in_view[d.id] = true; });
          if ($item.id in ids_in_view) {
            scope.notInView = false;

            var origValue = d3.select('#n'+$item.id).attr('r');
            d3.select('#n'+$item.id)
              .transition(5000).attr('r', 50)
              .transition(5000).attr('r', origValue);
          }
          else {
            scope.notInView = true;
          }
        }

        function checkForNameless(arr) {
          arr.forEach(function(a) {
            if (!a['name']) {
              return true;
            }
          });
        }
        scope.submitNode = function() {
          console.log("node submitted");
          var newNode = angular.copy(scope.newNode);

          if (scope.notInView === true && scope.addedNodes.length > 0 && !scope.addedNodes[scope.addedNodes.length-1].attributes.name) {
            scope.addedNodes[scope.addedNodes.length-1].attributes.name = newNode.name;
            newNode = angular.copy(scope.newNode);
          }
          else if (scope.notInView === true && (scope.addedNodes.length === 0 || !checkForNameless(scope.addedNodes))) {
            scope.newNode.id = scope.addedNodeId;
            var x = scope.singleWidth*(3/4)+scope.addedNodeId*20;
            var y = scope.singleHeight*(3/4)+scope.addedNodeId*20;
            var realNewNode = { attributes: { name: scope.newNode.name, degree: 1 }, id: scope.newNode.id, distance: 7, x: x, y: y};
            newNode = angular.copy(scope.newNode);
            console.log(realNewNode);
            realNewNode.vx = null;
            realNewNode.vy = null;
            scope.addedNodes.push(realNewNode);
          }
          newNode.created_by = scope.config.userId;
          newNode.birthDateType = newNode.birthDateType.abbr;
          newNode.deathDateType = newNode.deathDateType.abbr;
          scope.updateNetwork(scope.data);

          if (!scope.newNode.exists) { scope.addToDB.nodes.push(newNode); }
          scope.addNodeClosed = true;
          scope.newNode = {};
          scope.newNode.birthDateType = scope.newNode.deathDateType = scope.config.dateTypes[1];
          console.log(scope.addToDB);
          scope.config.added = true;

        }
      }
    };
  }]);
