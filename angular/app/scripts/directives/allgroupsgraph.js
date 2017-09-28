'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:allGroupsGraph
 * @description
 * # allGroupsGraph
 */
angular.module('redesign2017App')
  .directive('allGroupsGraph', ['apiService', '$timeout', function(apiService, $timeout) {
    return {
      template: '<svg width="100%" height="100%"></svg>',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        scope.allGroupSvg = d3.select(element[0]).select('svg');
        var width = +scope.allGroupSvg.node().getBoundingClientRect().width,
            chartWidth = width,
            height = +scope.allGroupSvg.node().getBoundingClientRect().height;

        var nodes = [];
        var links = [];
        scope.allGroupZoomfactor = 1;

        scope.addedGroups = [];

        var simulation = d3.forceSimulation(nodes)

          // set the center of the force layout, this schould not influence the general force field
          .force("center", d3.forceCenter(width / 2, height / 2))

          // attract all the nodes to the center of the scope.allGroupSvg
          // this result in a force that is summed up to the others
          // helpfull when you don't want nodes to be pushed outside the scope.allGroupSvg borders, since it LIMITS this behaviour
          .force("x", d3.forceX(width / 2))
          .force("y", d3.forceY(height / 2))

          // A force node employ among each others.
          // If the strength is negative, it results in a repulsion, if positive in an attraction
          // In this case we want node to repel themselves and then to attract depending on the connections they have in between each others
          .force("charge", d3.forceManyBody().strength(-400))

          // the force calculated depending on the nodes connections
          // it is possible to calculate the strength in this way: .strength(function(d){ return sizeEdge(d.weight)*0.35 })
          .force("link", d3.forceLink(links).id(function(d) { return d.id }).iterations(1))

          // Anti collision force
          // fed with the radious of the nodes (even if we're now using sqaures) incremented by 1, to leave a little breathe between nodes
          // Pay attention in using this: it makes the graph less cluttered, but it affect the truthfulness of the force layout.
          // A good strategy could be to not use this untill you're satisfacted by the concatenation of the previous forces
          // and then apply this just to be sure node are not overlapping. Indeed, in graphs, the position of the nodes should not depend
          // on the anticollision algorithm, but on the other forces you put on the canvas.
          // The risk is otherwise to depict something that is not totally true.
          .force("collide", d3.forceCollide(function(d) { return sizeScale(d.attributes.degree) + 1 }))
          // general force settings
          .alpha(1)
          .alphaDecay(0.02)
          .on("tick", ticked)

        scope.allGroupSvg.append("rect")
          .attr("width", width)
          .attr("height", height)
          .style("fill", "none")
          .style("pointer-events", "all")
          .on("click", function() {
            d3.selectAll('all-groups-graph .node, all-groups-graph g.label, all-groups-graph .link').classed('faded', false);

            if (scope.config.contributionMode) {
              var point = d3.mouse(scope.allGroupSvg.node());
              scope.addGroupNode(scope.addedGroups, point, scope.updateAllGroups);
            }
            // update selction and trigger event for other directives
            scope.currentSelection = {};
            scope.$apply(); // no need to trigger events, just apply
          })
          .on('mousemove', mousemove);


        var g = scope.allGroupSvg.append("g").attr("transform", "translate(" + (width / 2) * 0 + "," + (height / 2) * 0 + ")"),
          link = g.append("g").selectAll(".link"),
          node = g.append("g").selectAll(".node");

        var label = g.append("g").attr("class", "labels").selectAll(".label");

        var sizeScale = d3.scaleLinear()
          .range([8, 30]);

        var sizeEdge = d3.scaleLinear()
          .range([1, 10]);

        var cursor = scope.allGroupSvg.append("rect")
          // .attr("r", 12.5)
          .attr("width", 20)//function(d) { return (2 * sizeScale(d.attributes.degree)) / Math.sqrt(2); })
          .attr("height", 20)//function(d) { return (2 * sizeScale(d.attributes.degree)) / Math.sqrt(2); })
          .attr("rx", 2)
          .attr("ry", 2)
          .attr("fill", "none")
          .attr("stroke", "orange")
          .attr("stroke-width", 1.5)
          .attr('stroke-dasharray', 5,5)
          .attr("opacity", 0)//function() {
            // if (scope.config.contributionMode) {return 1;} else {return 0;}
          // })
          .attr("transform", "translate(-100,-100)")
          .attr("class", "cursor");

        scope.allGroupZoom = d3.zoom(); // Create a single zoom function
        // Call zoom for scope.allGroupSvg container.
        scope.allGroupSvg.call(scope.allGroupZoom.on('zoom', zoomed)).on("dblclick.zoom", null); // See zoomed() below

        function zoomed() {
          g.attr("transform", "translate(" + d3.event.transform.x + ", " + d3.event.transform.y + ") scale(" + d3.event.transform.k + ")");
        }

        scope.updateAllGroups = function() {

          var startTime = d3.now();

          function drawGraph() {
            var extentNodes = d3.extent(nodes, function(d) { return d.attributes.degree; }),
                extentEdges = d3.extent(links, function(d) { return d.weight; });

            var sizeLegend = d3.select('.legend-size-squares')
                .selectAll('.white-square')
                .data(extentNodes);

            var sizeLegendBox = sizeLegend.enter()
                .merge(sizeLegend);

            sizeLegendBox.append('div')
                .classed('white-square', true)
                .style("width", function(d) { return Math.floor((2 * sizeScale(d)) / Math.sqrt(2)) + 'px'; })
                .style("height", function(d) { return Math.floor((2 * sizeScale(d)) / Math.sqrt(2)) + 'px'; })
                .style("margin", function(d,i) { return i == 0 ? "0 24px 0 0" : "0 0 0 24px"; })
                .style("order", function(d,i) { return i == 0 ? 1 : 2; });

            sizeLegendBox.append('div')
                .classed('legend-text', true)
                .text(function(d){ return d; })
                .style("margin", "0 12px")
                .style("order", function(d,i){ return i == 0 ? 0 : 4; });

            sizeLegend.exit().remove();


            var weightLegend = d3.select('.legend-size-edges')
                .selectAll('.edge-line')
                .data(extentEdges);

            var weightLegendBox = weightLegend.enter()
                .merge(weightLegend);

            weightLegendBox.append('div')
                .classed('edge-line', true)
                .style("width", function(d) { return Math.floor(sizeEdge(d)) + 'px'; })
                .style("height", '30px')
                .style("order", function(d,i) { return i == 0 ? 1 : 2; });

            weightLegendBox.append('div')
                .classed('legend-text centered', true)
                .text(function(d){ return d; })
                .style("order", function(d,i){ return i == 0 ? 0 : 4; });

            weightLegend.exit().remove();

            scope.addedGroups.forEach(function(a) { nodes.push(a); });

            // Apply the general update pattern to the nodes.
            nodes.sort(function(x, y) {
              return d3.descending(x.attributes.degree, y.attributes.degree);
            })
            node = node.data(nodes, function(d) { return d.id; });
            node.exit().remove();
            node = node.enter().append("rect")
              .merge(node)
              .attr("class", "node")
              .attr("width", function(d) { return (2 * sizeScale(d.attributes.degree)) / Math.sqrt(2); })
              .attr("height", function(d) { return (2 * sizeScale(d.attributes.degree)) / Math.sqrt(2); })
              .attr("rx", 2)
              .attr("ry", 2)
              .classed("new", function(d) { return d.distance === 7; })
              .on("click", function(d) {
                // console.log(d, d.attributes.name)
                // Toggle ego networks on click of node
                toggleClick(d, this);
              })
              .on('dblclick', function(d){
                console.log('double clicked:',d);
                if (d.id !== 0) {
                  scope.groupSelected(d);
                } else {
                  console.log('new node');
                  scope.$apply(function() {
                    scope.config.viewMode = 'group-force';
                    scope.data = {};
                    scope.data.included = [];
                    scope.data.data = {};
                    scope.data.data.attributes = {};
                    scope.data.data.attributes.primary_people = [];
                    scope.data.data.attributes.connections = [];
                  });

                }
              })
              // On hover, display label
              .on('mouseenter', function(d) {
                d3.selectAll('all-groups-graph g.label').each(function(e) {
                  if (e.id == d.id) {
                    d3.select(this).classed('temporary-unhidden', true);
                  }
                })
                // // sort elements so to bring the hovered one on top and make it readable.
                scope.allGroupSvg.selectAll("all-groups-graph g.label").each(function(e, i) {
                  if (d == e) {
                    var myElement = this;
                    d3.select(myElement).remove();
                    d3.select('all-groups-graph .labels').node().appendChild(myElement);
                  }
                })
              })
              .on('mouseleave', function(d) {
                d3.selectAll('all-groups-graph g.label').each(function(e) {
                  if (e.id == d.id) {
                    d3.select(this).classed('temporary-unhidden', false);
                  }
                })
              })

            // Apply the general update pattern to the links.
            link = link.data(links, function(d) { return d.source.id + "-" + d.target.id; });
            link.exit().remove();
            link = link.enter().append("path")
              .merge(link)
              .attr("class", "link")
              .attr("stroke-width", function(d) { return sizeEdge(d.weight) })

            label = label.data(nodes, function(d) { return d.id; });
            label.exit().remove();
            label = label.enter().append("g")
              .merge(label)
              .attr("class", "label")
              .classed("not-visible", function(d, i) {
                return (i <= 10) ? false : true
              })

            label.append('rect')

            label.append('text')
              .text(function(d) {
                return d.attributes.name;
              })

            // Get the Bounding Box of the text created
            d3.selectAll('all-groups-graph .label text').each(function(d, i) {
              if (!d.labelBBox) {
                d.labelBBox = this.getBoundingClientRect();
              }
            });

            // adjust the padding values depending on font and font size
            var paddingLeftRight = 4;
            var paddingTopBottom = 0;

            // set dimentions and positions of rectangles depending on the BBox exctracted before
            d3.selectAll("all-groups-graph .label rect")
              .attr("x", function(d) {
                return 0 - d.labelBBox.width / 2 - paddingLeftRight / 2;
              })
              .attr("y", function(d) {
                return 0 + 3 - d.labelBBox.height + paddingTopBottom / 2;
              })
              .attr("width", function(d) {
                return d.labelBBox.width + paddingLeftRight;
              })
              .attr("height", function(d) {
                return d.labelBBox.height + paddingTopBottom;
              });

            // Change name of the viz
            scope.config.title = "A force layout of all the available groups"
          }

          drawGraph();

          // Update and restart the simulation.
          simulation.nodes(nodes);
          simulation.force("link").links(links);
          simulation.alpha(1).restart();

          simulation.on("end", function() {
            var endTime = d3.now();
            console.log('Spatialization completed in', (endTime - startTime) / 1000, 'sec.');
          })
        }

        function dragstarted(d) {
          simulation.restart();
          simulation.alpha(1.0);
          d.fx = d.x;
          d.fy = d.y;
        }

        function dragged(d) {
          d.fx = d3.event.x;
          d.fy = d3.event.y;
          simulation.alpha(1.0);
        }

        function dragended(d) {
          d.fx = null;
          d.fy = null;
        }

        function ticked() {
          node.attr("x", function(d) { return d.x - sizeScale(d.attributes.degree) / Math.sqrt(2) })
            .attr("y", function(d) { return d.y - sizeScale(d.attributes.degree) / Math.sqrt(2) })
            .style("transform-origin", function(d) {
              var translationValue = d.x + 'px ' + d.y + 'px';
              return translationValue;
            })

          link.attr("d", function(d) {
            return linkArc(d);
          })

          // Position labels in center of nodes
          label.attr("transform", function(d) {
            return "translate(" + (d.x) + "," + (d.y) + ")"
          })
        }

        // Move the circle with the mouse, until the the user clicks
        function mousemove() {
          cursor.attr("transform", "translate(" + d3.mouse(scope.allGroupSvg.node()) + ")");
          // if (scope.config.contributionMode) {
          //   fisheye.focus(d3.mouse(this));
          //
          //   node.each(function(d) { d.fisheye = fisheye(d); })
          //       .attr("cx", function(d) { return d.fisheye.x; })
          //       .attr("cy", function(d) { return d.fisheye.y; })
          //       .attr("r", function(d) {
          //         if (d.distance == 0) {
          //           return 25 * d.fisheye.z;
          //         } else if (d.distance == 1) {
          //           return 12.5 * d.fisheye.z;
          //         } else {
          //           return 6.25 * d.fisheye.z;
          //         }
          //       });
          //
          //   link.attr("d", function(d) {
          //         var dx = d.target.fisheye.x - d.source.fisheye.x,
          //           dy = d.target.fisheye.y - d.source.fisheye.y,
          //           dr = Math.sqrt(dx * dx + dy * dy);
          //         return "M" + d.source.fisheye.x + "," + d.source.fisheye.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.fisheye.x + "," + d.target.fisheye.y;
          //       });
          // }
        }

        // Draw curved edges, create d-value for link path
        function linkArc(d) {
          var dx = d.target.x - d.source.x,
            dy = d.target.y - d.source.y,
            dr = Math.sqrt(dx * dx + dy * dy); //Pythagoras!
          return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
        }

        // A function to handle click toggling based on neighboring nodes.
        function toggleClick(d, selectedElement, newLinks) {
          // console.log(d.attributes.name, d);

          if (d.type == "group") { //Handler for when a node is clicked
            // console.log("group")
            // Fade everything
            d3.selectAll('all-groups-graph .node, all-groups-graph g.label, all-groups-graph .link').classed('faded', true);

            // Unfade relevant things
            d3.select(selectedElement).classed('faded', false);
            d3.selectAll('all-groups-graph g.label').filter(function(e) {
              return e.id == d.id;
            }).classed('faded', false);

            // Find connected groups and unfade them
            links.forEach(function(l) {
              // console.log(l.source.id, l.target.id);
              if (d.id == l.source.id) {
                d3.selectAll('all-groups-graph .node, all-groups-graph .label').filter(function(e) {
                  return e.id == l.target.id
                }).classed('faded', false);
              } else if (d.id == l.target.id) {
                d3.selectAll('all-groups-graph .node, all-groups-graph .label').filter(function(e) {
                  return e.id == l.source.id
                }).classed('faded', false);
              }
            })

            // Find Connected edges and unfade them
            d3.selectAll('all-groups-graph .link').filter(function(e) {
              return e.source.id == d.id || e.target.id == d.id;
            }).classed('faded', false);


            // This triggers events in groupsbar.js and contextualinfopanel.js when a selection happens
            // scope.currentSelection = d;
            console.log(d.id);
            apiService.getGroups(d.id).then(function (result) {
              // console.log(result);
              scope.currentSelection = result.data[0];
              scope.currentSelection.type = 'group';
              // console.log(scope.currentSelection);
              console.log(scope.currentSelection);
              $timeout(function(){
                scope.$broadcast('selectionUpdated', scope.currentSelection);
              });
            });
            // scope.$broadcast('selectionUpdated', scope.currentSelection);

          } else if (d.type == "relationship") { //Handler for when a link is clicked

            console.log("relationship");

            // // Remove selction from nodes and labels
            // d3.selectAll('.node, g.label').classed('selected', false);

            // d3.selectAll('.link') // Show only selected link
            //   .classed('faded', function(l) {
            //     return (l == d) ? false : true;
            //   })

            // d3.selectAll('.node') // Show only source and target node
            //   .classed('faded', function(n) {
            //     return (n == d.source || n == d.target) ? false : true;
            //   })

            // d3.selectAll('g.label') // Show only source and target label
            //   .classed('hidden', function(m) {
            //     return (m == d.source || m == d.target) ? false : true;
            //   })

            // console.log('selection to be implemented');
            // // This triggers events in groupsbar.js and contextualinfopanel.js when a selection happens
            // scope.currentSelection = d;
            // scope.$broadcast('selectionUpdated', scope.currentSelection);
          }

        }

        scope.$watch('config.contributionMode', function(newValue, oldValue) {
          if (newValue !== oldValue) {
            if (scope.config.contributionMode) {
              cursor.attr("opacity", 1);
            }
            else {
              cursor.attr("opacity", 0);
            }
          }
        });

        // action triggered from the controller
        scope.$on('Show groups graph', function(event, json) {
          // console.log(event, json);
          nodes = [];
          nodes = json.included;
          var maxDegree = d3.max(nodes, function(d) { return d.attributes.degree; });
          var minDegree = d3.min(nodes, function(d) { return d.attributes.degree; });
          sizeScale.domain([minDegree, maxDegree]);
          links = [];
          json.data.attributes.connections.forEach(function(l) {
            links.push({
              'type': l.type,
              'source': l.attributes.source,
              'target': l.attributes.target,
              'weight': l.attributes.weight
            })
          })
          var minWeight = d3.min(links, function(d) { return d.weight });
          var maxWeight = d3.max(links, function(d) { return d.weight });
          scope.data = json;
          sizeEdge.domain([minWeight, maxWeight]);
          // console.log(nodes)
          scope.updateAllGroups();
        });

      }
    };
  }]);
