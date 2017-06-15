'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:smallTimeline
 * @description
 * # smallTimeline
 */
angular.module('redesign2017App')
  .directive('smallTimeline', function() {
    return {
      template: '<svg></svg>',
      restrict: 'E',
      scope: {
        details: '=',
      },
      link: function postLink(scope, element, attrs) {
        // console.log(scope.details)

        var svg = d3.select(element[0]).select('svg'),
          width = +svg.node().getBoundingClientRect().width,
          height = +svg.node().getBoundingClientRect().height;

        var x = d3.scaleLinear()
          .rangeRound([0, width])
          .domain([1450, 1750]);

        function update() {
          console.log('details', scope.details);

          // if the data type = relationship, we have start_date instead of birth_date and end_date instead of death_date
          // The way in which the data is computated is the same
          // All we need to do is just to change the structure of the data so that it respect the one of type = person

          if (scope.details.type == 'relationship') {
          	if (!scope.details.attributes) {
          		scope.details.attributes = {}
          	}
	          scope.details.attributes.birth_year = scope.details.start_year;
	          scope.details.attributes.death_year = scope.details.end_year;

	          if(scope.details.start_year_type) {
	          	scope.details.attributes.birth_year_type = scope.details.start_year_type
	          }
	          if(scope.details.end_year_type) {
	          	scope.details.attributes.death_year_type = scope.details.end_year_type
	          }
	          if(!scope.details.attributes.relationshipKind) {
	          	scope.details.attributes.relationshipKind = 'Kind undefined'
	          }
          }

          // calculate if birth and death years are too close together
          var delta = scope.details.attributes.death_year - scope.details.attributes.birth_year;

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
              return 'M' + x(scope.details.attributes.birth_year) + ',' + height / 2 + ' L' + x(scope.details.attributes.death_year) + ',' + height / 2;
            });

          svg.append('path')
            .attr('class', function(d) {
              var classes = (scope.details.attributes.birth_year_type == 'CA' || scope.details.attributes.birth_year_type == 'ca') ? 'terminator birth filled' : 'terminator birth';
              return classes;
            })
            .attr('d', function(d) {
              return terminators('birth', scope.details.attributes.birth_year_type, x(scope.details.attributes.birth_year), height / 2)
            });

          svg.append('path')
            .attr('class', function(d) {
              var classes = (scope.details.attributes.death_year_type == 'CA' || scope.details.attributes.death_year_type == 'ca') ? 'terminator birth filled' : 'terminator birth';
              return classes
            })
            .attr('d', function(d) {
              return terminators('death', scope.details.attributes.death_year_type, x(scope.details.attributes.death_year), height / 2)
            });

          svg.append('text')
            .attr('class', 'label life')
            .attr("x", function(d) {
              return x(scope.details.attributes.birth_year);
            })
            .attr("y", function(d) {
              return height / 2 - 8;
            })
            .classed("text-left", function(d) {
              return delta <= 25;
            })
            .text(scope.details.attributes.birth_year);

          svg.append('text')
            .attr('class', 'label life')
            .attr("x", function(d) {
              return x(scope.details.attributes.death_year);
            })
            .attr("y", function(d) {
              return height / 2 - 8;
            })
            .classed("text-right", function(d) {
              return delta <= 25;
            })
            .text(scope.details.attributes.death_year);

						if (scope.details.type == 'relationship') {
							svg.append('text')
		            .attr('class', 'label relationship')
		            .attr("x", width/2)
		            .attr("y", function(d) {
		              return height;
		            })
		            .text(scope.details.attributes.relationshipKind+' ('+scope.details.weight+'% confidence)');
						}
          // console.log('timeline drawn');
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
            return 'M' + refX + ',' + (refY - width / 2) + ' C' + (refX - width / 4) + ',' + (refY - width / 2) + ',' + (refX - width / 2) + ',' + (refY - width / 4) + ',' + (refX - width / 2) + ',' + refY + ' S' + (refX - width / 4) + ',' + (refY + width / 2) + ',' + refX + ',' + (refY + width / 2) + ' S' + (refX + width / 2) + ',' + (refY + width / 4) + ',' + (refX + width / 2) + ',' + (refY) + ', S' + (refX + width / 4) + ',' + (refY - width / 2) + ',' + (refX) + ',' + (refY - width / 2) + ' z';
          } else {
            console.warn('Missing property "'+position+'_year_type". Accepted values (lowercase or uppercase): AF, AF/IN, BF, BF/IN, IN, CA.');
          }
        }

        scope.$on('selectionUpdated', function(event, arg) {
          // console.log('update the timeline');
          update();
        });

      }
    };
  });
