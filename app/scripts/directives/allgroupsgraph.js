'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:allGroupsGraph
 * @description
 * # allGroupsGraph
 */
angular.module('redesign2017App')
  .directive('allGroupsGraph', function() {
    return {
      template: '<svg width="100%" height="100%"></svg>',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        var svg = d3.select(element[0]).select('svg'),
          width = svg.node().getBoundingClientRect().width,
          chartWidth = width,
          height = svg.node().getBoundingClientRect().height;

        var nodes = [];
        var links = [];

        var simulation = d3.forceSimulation(nodes)

          // set the center of the force layout, this schould not influence the general force field
          .force("center", d3.forceCenter(width / 2, height / 2))

          // attract all the nodes to the center of the svg
          // this result in a force that is summed up to the others
          // helpfull when you don't want nodes to be pushed outside the svg borders, since it LIMITS this behaviour
          .force("x", d3.forceX(width / 2))
          .force("y", d3.forceY(height / 2))

          // A force node employ among each others.
          // If the strength is negative, it results in a repulsion, if positive in an attraction
          // In this case we want node to repel themselves and then to attract depending on the connections they have in between each others
          .force("charge", d3.forceManyBody().strength(-300))

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

        svg.append("rect")
          .attr("width", width)
          .attr("height", height)
          .style("fill", "none")
          .style("pointer-events", "all")
          .call(d3.zoom()
            .scaleExtent([1 / 2, 4])
            .on("zoom", zoomed));

        function zoomed() {
          g.attr("transform", d3.event.transform);
        }

        var g = svg.append("g").attr("transform", "translate(" + (width / 2) * 0 + "," + (height / 2) * 0 + ")"),
          link = g.append("g").selectAll(".link"),
          node = g.append("g").selectAll(".node");

        var label = g.append("g").attr("class", "labels").selectAll(".label");

        var sizeScale = d3.scaleLinear()
          .range([8, 30]);

        var sizeEdge = d3.scaleLinear()
          .range([1, 10]);

        function update() {

          var startTime = d3.now();

          function drawGraph() {
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
              .on("click", function(d) {
                console.log(d, d.attributes.name)
                // Toggle ego networks on click of node
                // toggleClick(d, newLinks, this);
              })
              // On hover, display label
              .on('mouseenter', function(d) {
                d3.selectAll('all-groups-graph g.label').each(function(e) {
                  if (e.id == d.id) {
                    d3.select(this).classed('temporary-unhidden', true);
                  }
                })
                // // sort elements so to bring the hovered one on top and make it readable.
                svg.selectAll("all-groups-graph g.label").each(function(e, i) {
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
            d3.selectAll('.label text').each(function(d, i) {
              if (!d.labelBBox) {
                d.labelBBox = this.getBBox();
              }
            });

            // adjust the padding values depending on font and font size
            var paddingLeftRight = 4;
            var paddingTopBottom = 0;

            // set dimentions and positions of rectangles depending on the BBox exctracted before
            d3.selectAll(".label rect")
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

        // Draw curved edges, create d-value for link path
        function linkArc(d) {
          var dx = d.target.x - d.source.x,
            dy = d.target.y - d.source.y,
            dr = Math.sqrt(dx * dx + dy * dy); //Pythagoras!
          return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
        }

        // A function to handle click toggling based on neighboring nodes.
        function toggleClick(d, newLinks, selectedElement) {

          // Reset group bar
          d3.selectAll('.group').classed('active', false);
          d3.selectAll('.group').classed('unactive', false);

          if (d.type == "person") { //Handler for when a node is clicked

            // Handle signifier for selected node
            d3.selectAll('.node, g.label').classed('selected', false);
            d3.select(selectedElement).classed('selected', true);
            d3.selectAll('g.label').filter(function(e) {
              return e.id == d.id;
            }).classed('selected', true);

            // Make object of all neighboring nodes.
            var connectedNodes = {};
            connectedNodes[d.id] = true;
            newLinks.forEach(function(l) {
              if (l.source.id == d.id) {
                connectedNodes[l.target.id] = true;
              } else if (l.target.id == d.id) {
                connectedNodes[l.source.id] = true;
              };
            });

            // Restyle links, nodes and labels
            d3.selectAll('.link')
              .classed('faded', function(l) {
                if (l.target.id != d.id && l.source.id != d.id) {
                  return true;
                };
              })

            d3.selectAll('.node')
              .classed('faded', function(n) {
                if (n.id in connectedNodes) {
                  return false
                } else {
                  return true;
                };
              })

            // Get number of connections (degree) for each node
            // Must calculate it every time, because it can change according to thresholds
            var numberOfConnections = Object.keys(connectedNodes).length;


            // If fewer than 20 connections, show all labels
            if (numberOfConnections <= 20) {
              d3.selectAll('g.label')
                .classed('hidden', function(m) {
                  return !(m.id in connectedNodes);
                });
            } else { // If more than 20 connections, show only top-20 labels by confidence (weight)
              var neighborsByConfidence = [];
              for (var m in connectedNodes) { // Get confidence for all connected neighbors
                newLinks.forEach(function(l) {
                  if ((l.source.id == m && l.target.id == d.id) || (l.source.id == d.id && l.target.id == m)) {
                    neighborsByConfidence.push([m, l.weight]);
                  }
                });
              }

              // Sort neighbors by confidence
              neighborsByConfidence.sort(function(first, second) {
                return second[1] - first[1];
              });

              var top20 = neighborsByConfidence.slice(0, 20); // Get only the top 20

              // Convert to object for easy iteration
              var top20object = {};
              top20.forEach(function(t) { top20object[t[0]] = t[1]; });

              // Restyle top 20 labels only
              d3.selectAll('g.label')
                .classed('hidden', function(m) {
                  if (m.id != d.id) {
                    return (m.id in top20object) ? false : true;
                  } else {
                    return false;
                  }
                });
            }

            // This triggers events in groupsbar.js and contextualinfopanel.js when a selection happens
            scope.currentSelection = d;
            scope.$broadcast('selectionUpdated', scope.currentSelection);

          } else if (d.type == "relationship") { //Handler for when a link is clicked

            // Remove selction from nodes and labels
            d3.selectAll('.node, g.label').classed('selected', false);

            d3.selectAll('.link') // Show only selected link
              .classed('faded', function(l) {
                return (l == d) ? false : true;
              })

            d3.selectAll('.node') // Show only source and target node
              .classed('faded', function(n) {
                return (n == d.source || n == d.target) ? false : true;
              })

            d3.selectAll('g.label') // Show only source and target label
              .classed('hidden', function(m) {
                return (m == d.source || m == d.target) ? false : true;
              })

            console.log('selection to be implemented');
            // This triggers events in groupsbar.js and contextualinfopanel.js when a selection happens
            scope.currentSelection = d;
            scope.$broadcast('selectionUpdated', scope.currentSelection);
          }

        }

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
          sizeEdge.domain([minWeight, maxWeight]);
          // console.log(nodes)
          update();
        });

      }
    };
  });
