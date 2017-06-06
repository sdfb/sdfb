'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:groupsBar
 * @description
 * # groupsBar
 */
angular.module('redesign2017App')
  .directive('groupsBar', function() {
    return {
      template: '',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {

        var x = d3.scaleLinear()
        updateGroupBar(scope.groups);

        function updateGroupBar(data) {
          
          // size of the group bar
          var oldWidth = d3.select(element[0]).node().getBoundingClientRect().width;
          var padding = 5;
          var width = d3.select(element[0]).node().getBoundingClientRect().width - 20 - padding * 20;

          // calculate total number of people
          var total = 0;
          data.groupsBar.forEach(function(d) {
            total += d.value;
          })

          // set dimentions for scales
          x.domain([0, total]);
          x.range([0, width]);

          // declare chart
          var chart = d3.select(element[0]).selectAll('group')
            .data(data.groupsBar);

          // append stuff
          chart.enter()
            .append('div')
            .attr('class', function(d, i) {
              if (i == 20) {
                var className = 'group';
                data.otherGroups.forEach(function(e) {
                  className += ' g';
                  className += e.groupId;
                })
                return className;
              } else {
                return 'group g' + d.groupId;
              }
            })
            .style('width', function(d) {
              var myWidth = x(d.value) / (width) * 100;
              var newTot = width / oldWidth * 100;
              var value = (myWidth * newTot) / 100;
              return value + '%';
            })
            .merge(chart)
            .text(function(d, i) {
              if (i == 20) {
                return d.value + ' minor groups (click to show)'
              } else {
                return 'g' + d.groupId;
              }
            })
            .on('click', function(d, i) {
              if (i == 20) {
                scope.open();
              } else {
                return;
              }
            });

          // remove stuff
          chart.exit().remove();
        }

        // HIGHLIGHT GROUPS WHEN SELECTION HAPPENS
        // This works for individual force layout only, at the moment
        scope.$on('selectionUpdated', function(event, args) {
          // console.log(args);
          if (args) {
            d3.selectAll('.group').classed('unactive', true);
            if (args.attributes.groups) {
              args.attributes.groups.forEach(function(d) {
                var selectClass = '.g' + d;
                // console.log(selectClass, d3.selectAll(selectClass));
                d3.selectAll(selectClass).classed('active', true);
                d3.selectAll(selectClass).classed('unactive', false);
              });
            }
          }
        })

      }
    };
  });
