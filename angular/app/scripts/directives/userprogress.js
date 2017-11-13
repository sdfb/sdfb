'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:userProgress
 * @description
 * # smallTimeline
 */
angular.module('redesign2017App')
  .directive('userProgress', ['apiService', '$timeout', function(apiService, $timeout) {
    return {
      template: '',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {

        var svg = d3.select(element[0]).append('svg'),
          width = 300,
          height = 30;

        var x = d3.scaleLinear()
          .rangeRound([0, width])
          .domain([0, 100]);


        function update() {

            makeTimeline();


          function makeTimeline() {
            // calculate if birth and death years are too close together
            // var delta = scope.currentSelection.attributes.death_year - scope.currentSelection.attributes.birth_year;

            if (scope.user.points >= 100) {
              scope.endpoint = 100;
            } else {
              scope.endpoint = scope.user.points;
            }

            svg.selectAll('*').remove();

            svg.append('path')
              .attr('class', 'background-line')
              .attr('d', function(d) {
                return 'M' + x(x.domain()[0]) + ',' + height / 2 + ' L' + x(x.domain()[1]) + ',' + height / 2;
              });

            svg.append('text')
              .attr('class', 'label domain')
              .attr("x", function(d) {
                return x(x.domain()[0]);
              })
              .attr("y", function(d) {
                return height / 2 - 6;
              })
              .text(function(d) {
                return x.domain()[0]
              });

            svg.append('text')
              .attr('class', 'label domain')
              .attr('text-anchor', 'end')
              .attr("x", function(d) {
                return x(x.domain()[1]);
              })
              .attr("y", function(d) {
                return height / 2 - 6;
              })
              .text(function(d) {
                return x.domain()[1]
              });

            svg.append('path')
              .attr('class', 'life')
              .attr('d', function(d) {
                return 'M' + x(0) + ',' + height / 2 + ' L' + x(scope.endpoint) + ',' + height / 2;
              });

            svg.append('path')
              .attr('class', function(d) {
                return 'terminator birth';
              })
              .attr('d', function(d) {
                return terminators('birth', 'IN', x(0), height / 2)
              });

            svg.append('path')
              .attr('class', function(d) {
                return 'terminator birth';
              })
              .attr('d', function(d) {
                return terminators('death', 'IN', x(scope.endpoint), height / 2)
              });

            // svg.append('text')
            //   .attr('class', 'label life')
            //   .attr("x", function(d) {
            //     return x(scope.currentSelection.attributes.birth_year);
            //   })
            //   .attr("y", function(d) {
            //     return height / 2 - 8;
            //   })
            //   .classed("text-left", function(d) {
            //     return delta <= 25;
            //   })
            //   .text(scope.currentSelection.attributes.birth_year);

            svg.append('text')
              .attr('class', 'label life')
              .attr("x", function(d) {
                return x(scope.endpoint);
              })
              .attr("y", function(d) {
                return height / 2 + 12;
              })
              .text(scope.endpoint);

  						// if (scope.currentSelection.type == 'relationship') {
              //
  						// 	svg.append('text')
  		        //     .attr('class', 'label relationship')
  		        //     .attr("x", width/2)
  		        //     .attr("y", function(d) {
  		        //       return height;
  		        //     })
  		        //     .text(rel_types[scope.currentSelection.attributes.relationshipKind]+' ('+scope.currentSelection.attributes.confidence+'% confidence)');
  						// }
            }
        }

        function terminators(position, type, refX, refY, width) {
          if (!width) { width = 9 }
          if (type == 'AF' || type == 'af') {
            refX = (position == 'birth') ? (refX - width / 3) : (refX + width / 3)
            return 'M' + (refX + width / 2) + ',' + (refY - width / 2) + ' C' + (refX + width / 4) + ',' + (refY - width / 2) + ' ' + refX + ',' + (refY - width / 4) + ' ' + refX + ',' + refY + ' S' + (refX + width / 4) + ',' + (refY + width / 2) + ' ' + (refX + width / 2) + ',' + (refY + width / 2);

          } else if (type == 'AF/IN' || type == 'af/in') {
            return 'M' + (refX + width / 2) + ',' + (refY - width / 2) + ' C' + (refX + width / 4) + ',' + (refY - width / 2) + ' ' + refX + ',' + (refY - width / 4) + ' ' + refX + ',' + refY + ' S' + (refX + width / 4) + ',' + (refY + width / 2) + ' ' + (refX + width / 2) + ',' + (refY + width / 2);

          } else if (type == 'BF' || type == 'bf') {
            refX = (position == 'birth') ? (refX - width / 3) : (refX + width / 3)
            return 'M' + (refX - width / 2) + ',' + (refY - width / 2) + ' C' + (refX - width / 4) + ',' + (refY - width / 2) + ' ' + refX + ',' + (refY - width / 4) + ' ' + refX + ',' + refY + ' S' + (refX - width / 4) + ',' + (refY + width / 2) + ' ' + (refX - width / 2) + ',' + (refY + width / 2);

          } else if (type == 'BF/IN' || type == 'bf/in') {
            return 'M' + (refX - width / 2) + ',' + (refY - width / 2) + ' C' + (refX - width / 4) + ',' + (refY - width / 2) + ' ' + refX + ',' + (refY - width / 4) + ' ' + refX + ',' + refY + ' S' + (refX - width / 4) + ',' + (refY + width / 2) + ' ' + (refX - width / 2) + ',' + (refY + width / 2);

          } else if (type == 'IN' || type == 'in') {
            return 'M' + (refX) + ',' + (refY - width / 2) + ' L' + (refX) + ',' + (refY + width / 2);

          } else if (type == 'CA' || type == 'ca') {
            return 'M' + refX + ',' + (refY - width / 2) + ' C' + (refX - width / 4) + ',' + (refY - width / 2) + ',' + (refX - width / 2) + ',' + (refY - width / 4) + ',' + (refX - width / 2) + ',' + refY + ' S' + (refX - width / 4) + ',' + (refY + width / 2) + ',' + refX + ',' + (refY + width / 2) + ' S' + (refX + width / 2) + ',' + (refY + width / 4) + ',' + (refX + width / 2) + ',' + (refY) + ' S' + (refX + width / 4) + ',' + (refY - width / 2) + ',' + (refX) + ',' + (refY - width / 2) + ' z';
          } else {
            console.warn('Missing property "'+position+'_year_type". Accepted values (lowercase or uppercase): AF, AF/IN, BF, BF/IN, IN, CA.');
          }
        }

        // scope.$on('selectionUpdated', function(event, arg) {
          // scope.currentSelection = arg;
          update();
        // });
      }
    };
  }]);
