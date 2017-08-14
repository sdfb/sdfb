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
        // updateGroupBar(scope.groups);

        // console.log('on')
        // scope.$on('Update the groups bar', function(event, args){
        //   console.log(event, args)
        // })

        scope.updateGroupBar = function(data) {
          console.log("Updating groups bar...");

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

          var chartContainer = d3.select(element[0]).append('span').attr('class', 'groupBar');

          // declare chart
          var chart = chartContainer.selectAll('group')
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
            // tooltip-placement="{{placement.selected}}" uib-tooltip="On the {{placement.selected}}"
            .attr("data-toggle", function(d,i){
              return (i<20)?'group-tooltip':'other-groups-tooltip'
            })
            .attr("data-placement", "top")
            .attr("title", function(d) { return d.name; })
            .style('width', function(d) {
              var myWidth = x(d.value) / (width) * 100;
              var newTot = width / oldWidth * 100;
              var value = (myWidth * newTot) / 100;
              return value + '%';
            })
            .merge(chart)
            .text(function(d, i) {
              if (i == 20) {
                return d.amount + ' minor groups (click to show)'
              } else {
                return d.name;
              }
            })
            .on('click', function(d, i) {
              if (i == 20) {
                scope.open();
              } else {
                return;
              }
            })
            .on('mouseenter', function(d, i) {
              if (i < 20) {
                d3.selectAll('.link').classed('not-in-group', true);
                // assign class in-group or not-in-group to labels and to nodes
                d3.selectAll('g.label, .node').each(function(n) {
                  var className = 'not-in-group';
                  if (n.attributes.groups) {
                    var inGroup = n.attributes.groups.filter(function(e) {
                      return e == d.groupId;
                    })
                    if (inGroup.length) {
                      className = 'in-group';
                      // hide or display groups depending on group membership of source and target
                      d3.selectAll('.link').filter(function(f) {
                        var linkClassName = 'not-in-group';
                        if (f.source.attributes.groups && f.target.attributes.groups) {
                          // console.log(f.source.attributes.groups, f.target.attributes.groups);
                          var sourceInGroup = inGroup.some(function (e) {
                            return f.source.attributes.groups.indexOf(e) != -1 });
                          var targetInGroup = inGroup.some(function(e) {
                            return f.target.attributes.groups.indexOf(e) != -1 });
                          if (sourceInGroup && targetInGroup) {
                            linkClassName = 'in-group';
                          }
                          d3.select(this).classed(linkClassName, true);
                        }
                      })
                    }
                  }
                  d3.select(this).classed(className, true);
                })
                d3.selectAll('.link').classed('not-in-group', true);
              } else {
                d3.selectAll('g.label, .node').each(function(n) {
                  var className = 'not-in-group';
                  if (n.attributes.groups) {
                    var inGroup = _.intersectionWith(scope.groups.otherGroups, n.attributes.groups, function(a, b) {
                      return a.groupId == b;
                    });
                    if (inGroup.length) {
                      className = 'in-group'
                        // hide or display groups depending on group membership of source and target
                      d3.selectAll('.link').filter(function(f) {
                        var linkClassName = 'not-in-group';
                        if (f.source.attributes.groups && f.target.attributes.groups) {
                          // console.log(f.source.attributes.groups, f.target.attributes.groups);
                          var sourceInGroup = inGroup.some(function(e) {
                            return f.source.attributes.groups.indexOf(e) != -1 });
                          var targetInGroup = inGroup.some(function(e) {
                            return f.target.attributes.groups.indexOf(e) != -1 });
                          if (sourceInGroup && targetInGroup) {
                            linkClassName = 'in-group';
                          }
                          d3.select(this).classed(linkClassName, true);
                        }
                      })
                    }
                  }
                  d3.select(this).classed(className, true);
                })
                d3.selectAll('.link').classed('not-in-group', true);
              }
            })
            .on('mouseleave', function(d) {
              d3.selectAll('.node, .label, .link').classed('not-in-group', false);
              d3.selectAll('.node, .label, .link').classed('in-group', false);
            });

          // remove stuff
          chart.exit().remove();

          $(function() {
            $('[data-toggle="group-tooltip"]').tooltip({'animation':true})
          })
        }

        // HIGHLIGHT GROUPS WHEN SELECTION HAPPENS
        // This works for individual force layout only, at the moment
        scope.$on('selectionUpdated', function(event, args) {
          // console.log(args);
          if (args.type == 'person') {
            d3.selectAll('.group').classed('unactive', true);
            if (args.attributes.groups) {
              args.attributes.groups.forEach(function(d) {
                var selectClass = '.g' + d;
                d3.selectAll(selectClass).classed('active', true);
                d3.selectAll(selectClass).classed('unactive', false);
              });
            }
          } else if (args.type == 'relationship') {

            d3.selectAll('.group').classed('unactive', true);

            if (args.source.attributes.groups) {
              args.source.attributes.groups.forEach(function(d) {
                var selectClass = '.g' + d;
                d3.selectAll(selectClass).classed('active', true);
                d3.selectAll(selectClass).classed('unactive', false);
              });
            }

            if (args.target.attributes.groups) {
              args.target.attributes.groups.forEach(function(d) {
                var selectClass = '.g' + d;
                d3.selectAll(selectClass).classed('active', true);
                d3.selectAll(selectClass).classed('unactive', false);
              });
            }

          }
        })

      }
    };
  });
