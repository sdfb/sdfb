'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:peopleFinder
 * @description
 * # peopleFinder
 */
angular.module('redesign2017App')
  .directive('peopleFinder', function () {
    return {
      templateUrl: './views/people-finder.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {

          createSearchBox();

          function createSearchBox() {
            // Create form for search.
            var search = d3.select('.search-container').append('form').attr('onsubmit', 'return false;');
            var box = search.append('input')
            .classed('form-control', true)
             .attr('type', 'text')
             .attr('id', 'searchTerm')
             .attr('placeholder', 'Type to search...')
             .on('input', function() {
               searchNodes();
             });
          }

          // Search for nodes by displaying labels for matches.
          function searchNodes() {

            /*
            Remove any selected nodes or edges
            */

            d3.selectAll('.node, g.label').classed('selected', false);

            // Restore nodes and links to normal opacity. (see toggleClick() below)
            d3.selectAll('.link')
              .classed('faded', false)

            d3.selectAll('.node')
              .classed('faded', false)

            // Must select g.labels since it selects elements in other part of the interface
            d3.selectAll('g.label')
              .classed('hidden', function(d) {
                return (d.distance < 2) ? false : true;
              });

            // reset group bar
            d3.selectAll('.group').classed('active', false);
            d3.selectAll('.group').classed('unactive', false);

            // update selction and trigger event for other directives
            scope.currentSelection = {};
            scope.$apply(); // no need to trigger events, just apply

           /*
           Simple search to display labels
           */
           var term = document.getElementById('searchTerm').value;

           d3.selectAll('.label').classed('hidden', function(l) {
             return (l.attributes.name.toLowerCase().search(term.toLowerCase()) != -1) ? false : true;
           });
          }
      }
    };
  });
