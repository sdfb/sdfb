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
            // var button = search.append('input')
            // .classed('btn btn-primary', true)
            //  .attr('type', 'button')
            //  .attr('value', 'Search')
            //  .on('click', function() {
            //    searchNodes();
            //  });
          }

          // Search for nodes by making all unmatched nodes temporarily transparent.
          function searchNodes() {
           var term = document.getElementById('searchTerm').value;
          //  var selectedNodes = d3.selectAll('.node').filter(function(d, i) {
          //    return d.attributes.name.toLowerCase().search(term.toLowerCase()) == -1;
          //  });
           d3.selectAll('.label').classed('hidden', function(l) {
             return (l.attributes.name.toLowerCase().search(term.toLowerCase()) != -1) ? false : true;
           });
          //  selectedNodes.style('opacity', '0');
          //  selectedLabels.style('opacity', '0');
          //  var link = d3.selectAll('.link');
          //  link.style('stroke-opacity', '0');
          //  d3.selectAll('.node').transition().duration(5000).style('opacity', '1');
          //  link.transition().duration(5000).style('stroke-opacity', '0.6');
          //  d3.selectAll('.label').transition().duration(5000).style('opacity', '1');
          }
      }
    };
  });
