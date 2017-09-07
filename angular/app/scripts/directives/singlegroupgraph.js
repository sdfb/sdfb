'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:singleGroupGraph
 * @description
 * # singleGroupGraph
 */
angular.module('redesign2017App')
  .directive('singleGroupGraph', function() {
    return {
      template: '<svg id="single-group" width="100%" height="100%"></svg>',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        var svg = d3.select(element[0]).select('svg'),
          width = svg.node().getBoundingClientRect().width,
          chartWidth = width,
          height = svg.node().getBoundingClientRect().height;

        var nodes = [];
        var links = [];
        var members = [];
        var zoomfactor = 1;

        var simulation = d3.forceSimulation(nodes)
          .force("center", d3.forceCenter(width / 2, height / 2))
          .force("x", d3.forceX(width / 2))
          .force("y", d3.forceY(height / 2))
          .force("charge", d3.forceManyBody().strength(-300))
          .force("link", d3.forceLink(links).id(function(d) { return d.id }).iterations(1))
          .force("collide", d3.forceCollide(function(d) { return sizeScale(d.attributes.degree) + 1 }).iterations(0))
          .alpha(1)
          .alphaDecay(0.05)
          .on("tick", ticked);

        svg.append("rect")
          .attr("width", width)
          .attr("height", height)
          .style("fill", "none")
          .style("pointer-events", "all")
          // .call(zoom
            // .scaleExtent([1 / 2, 4])
            // .on("zoom", zoomed))
          .on("click", function() {
            d3.selectAll('#single-group .node, #single-group .link').classed('faded', false);
            d3.selectAll('#single-group g.label').classed("hidden", function(d, i) {
              return (i <= 10) ? false : true;
            });
            // update selction and trigger event for other directives
            scope.currentSelection = {};
            scope.$apply(); // no need to trigger events, just apply
          });

        var zoom = d3.zoom(); // Create a single zoom function
        // Call zoom for svg container.
        svg.call(zoom.on('zoom', zoomed)); //.on("dblclick.zoom", null); // See zoomed() below

        function zoomed() {
          g.attr("transform", "translate(" + d3.event.transform.x + ", " + d3.event.transform.y + ") scale(" + d3.event.transform.k + ")");
        }

        //Functions for zoom and recenter buttons
        scope.centerNetwork = function() {
          console.log("Recenter");
          // Transition source node to center of rect
          svg.transition().duration(750).call(zoom.transform, d3.zoomIdentity);
        }

        scope.zoomIn = function() {
          console.log("Zoom In")
          svg.transition().duration(500).call(zoom.scaleBy, zoomfactor + .5); // Scale by adjusted zoomfactor
        }
        scope.zoomOut = function() {
          console.log("Zoom Out")
          svg.transition().duration(500).call(zoom.scaleBy, zoomfactor - .25); // Scale by adjusted zoomfactor, slightly lower since zoom out was more dramatic
        }

        var g = svg.append("g").attr("transform", "translate(" + (width / 2) * 0 + "," + (height / 2) * 0 + ")"),
          link = g.append("g").selectAll(".link"),
          node = g.append("g").selectAll(".node");
        var label = g.append("g").attr("class", "labels").selectAll(".label");

        var sizeScale = d3.scaleLinear()
          .range([8, 30]);

        var sizeEdge = d3.scaleLinear()
          .range([1, 10]);

        function update(json, onlyMembers) {
          var startTime = d3.now();
          // Format data
          members = [];
          members = json.data.attributes.primary_people;
          console.log(members);
          nodes = [];
          links = [];
          var excludedNodes = [];
          if (onlyMembers) {
            // console.log('tot nodes:',json.included.length);
            nodes = _.intersectionWith(json.included, members, function(a, b) {
              return a.id == b;
            });
            nodes.forEach(function(n) {
              n['membership'] = true;
            })
            var noMemberNodes = _.differenceWith(json.included, members, function(a, b) {
              return a.id == b;
            });
            // console.log('members:',nodes.length,'- noMembers:', noMemberNodes.length);
            json.data.attributes.connections.forEach(function(l) {
              links.push({
                'type': l.type,
                'source': l.attributes.source,
                'target': l.attributes.target,
                'weight': l.attributes.weight
              })
            })
            // console.log('links', links.length)
            var linksToMembers = [];
            nodes.forEach(function(n1) {
              nodes.forEach(function(n2) {
                links.forEach(function(l) {
                  if (l.source == n1.id && l.target == n2.id) {
                    linksToMembers.push(l);
                  } else if (l.source == n2.id && l.target == n1.id) {
                    linksToMembers.push(l);
                  }
                })
              })
            })
            // console.log('links between members',linksToMembers.length)
            links = linksToMembers;
          } else {
            nodes = json.included;
            nodes.forEach(function(n) {
              n['membership'] = false;
            })
            members.forEach(function(m) {
              nodes.forEach(function(n) {
                if (n.id == m) {
                  n['membership'] = true;
                }
              })
            })
            json.data.attributes.connections.forEach(function(l) {
              links.push({
                'type': l.type,
                'source': l.attributes.source,
                'target': l.attributes.target,
                'weight': l.attributes.weight
              })
            })
          }

          var maxDegree = d3.max(nodes, function(d) { return d.attributes.degree; });
          var minDegree = d3.min(nodes, function(d) { return d.attributes.degree; });
          sizeScale.domain([minDegree, maxDegree]);

          var minWeight = d3.min(links, function(d) { return d.weight });
          var maxWeight = d3.max(links, function(d) { return d.weight });

          sizeEdge.domain([minWeight, maxWeight]);

          // draw things
          function drawGraph() {
            // Apply the general update pattern to the nodes.

            // scorporate nodes with membership and sort them
            var arrPart1 = nodes.filter(function(e) {
              return e.membership == true
            }).sort(function(x, y) {
              return d3.descending(x.attributes.degree, y.attributes.degree);
            })

            var arrPart2 = nodes.filter(function(e) {
              return e.membership == false
            })

            // console.log(arrPart1.length, arrPart2.length)

            var extent = d3.extent(nodes, function(d) {return d.attributes.degree;});

            var sizeLegend = d3.select('.legend-size .flex-container')
                .selectAll('.legend-circle')
                .data(extent);

            var sizeLegendBox = sizeLegend.enter()
                .merge(sizeLegend);

            sizeLegendBox.append('div')
                .classed('flex-item legend-circle white-circle', true)
                .style("width", function(d) { return (2 * sizeScale(d)) + 'px'; })
                .style("height", function(d) { return (2* sizeScale(d)) + 'px'; })
                // .style("margin", function(d,i) { return i == 0 ? "0 24px 0 0" : "0 0 0 24px"; })
                .style("order", function(d,i) { return i == 0 ? 1 : 2; });

            sizeLegendBox.append('div')
                .classed('legend-text', true)
                .text(function(d){ return d; })
                // .style("margin", "0 12px")
                .style("order", function(d,i){ return i == 0 ? 0 : 4; });

            sizeLegend.exit().remove();


            // Put them back together
            nodes = _.concat(arrPart1, arrPart2);

            node = node.data(nodes, function(d) { return d.id; });
            node.exit().remove();
            node = node.enter().append("circle")
              .merge(node)
              .attr("class", "node")
              .classed('member', function(d) {
                return members.filter(function(e) { return e == d.id; }).length > 0;
              })
              .attr("r", function(d) { return sizeScale(d.attributes.degree); })
              .on("click", function(d) {
                toggleClick(d, this);
              })
              .on("dblclick", function(d) {
                console.log('Try to go in individual-force', d);
              })
              // On hover, display label
              .on('mouseenter', function(d) {
                // console.log(d, this);
                d3.selectAll('single-group-graph g.label').classed('temporary-unhidden', function(e) {
                  return (e.id == d.id) ? true: false;
                })
                // sort elements so to bring the hovered one on top and make it readable.
                svg.selectAll("single-group-graph g.label").each(function(e, i) {
                  if (d == e) {
                    var myElement = this;
                    d3.select(myElement).remove();
                    d3.select('single-group-graph .labels').node().appendChild(myElement);
                  }
                })
              })
              .on('mouseleave', function(d) {
                d3.selectAll('single-group-graph g.label').classed('temporary-unhidden', function(e) {
                  if (e.id == d.id) { return false; }
                })
              });



            // Apply the general update pattern to the links.
            link = link.data(links, function(d) { return d.source.id + "-" + d.target.id; });
            link.exit().remove();
            link = link.enter().append("path")
              .merge(link)
              .attr("class", "link")
              .on('click', function(d) {
                // Toggle ego networks on click of node
                toggleClick(d, this);
              });

            label = label.data(nodes, function(d) { return d.id; });
            label.exit().remove();
            label = label.enter().append("g")
              .merge(label)
              .attr("class", "label")
              .classed("hidden", function(d, i) {
                return (i <= 10) ? false : true
              });

            label.append('rect');
            label.append('text')
              .text(function(d) {
                return d.attributes.name;
              })
            // Get the Bounding Box of the text created
            d3.selectAll('.label text').each(function(d, i) {
              if (!d.labelBBox) {
                d.labelBBox = this.getBoundingClientRect();
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

            // Change name of the viz
            scope.config.title = "Virginia Company - Force Layout"
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
          node.attr("cx", function(d) { return d.x; })
            .attr("cy", function(d) { return d.y; })

          link.attr("d", function(d) {
            return linkArc(d);
          })
          // Position labels in center of nodes
          label.attr("transform", function(d) {
            return "translate(" + (d.x) + "," + (d.y) + ")"
          })
          if (simulation.alpha() < 0.007 && simulation.force("collide").iterations() == 0) {
            simulation.force("collide").iterations(1).radius(function(d) { return sizeScale(d.attributes.degree) + 1 });
          }
        }

        // Draw curved edges, create d-value for link path
        function linkArc(d) {
          var dx = d.target.x - d.source.x,
            dy = d.target.y - d.source.y,
            dr = Math.sqrt(dx * dx + dy * dy); //Pythagoras!
          return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
        }

        function toggleClick(d, selectedElement) {
          // console.log(d, selectedElement);
          //Handler for when a node is clicked
          if (d.type == "person") {
            // Fade everything
            d3.selectAll('single-group-graph .node, single-group-graph .link').classed('faded', true);
            // Unfade relevant things
            d3.select(selectedElement).classed('faded', false);
            d3.selectAll('single-group-graph g.label').classed('hidden', function(e) {
              return (e.id == d.id) ? false: true;
            });
            // Find connected groups and unfade them
            links.forEach(function(l) {
              // console.log(l.source.id, l.target.id);
              if (d.id == l.source.id) {
                d3.selectAll('single-group-graph .node, single-group-graph .label').filter(function(e) {
                  return e.id == l.target.id
                }).classed('faded', false).classed('hidden', false);
              } else if (d.id == l.target.id) {
                d3.selectAll('single-group-graph .node, single-group-graph .label').filter(function(e) {
                  return e.id == l.source.id
                }).classed('faded', false).classed('hidden', false);
              }
            })
            // Find Connected edges and unfade them
            d3.selectAll('single-group-graph .link').filter(function(e) {
              return e.source.id == d.id || e.target.id == d.id;
            }).classed('faded', false);
            // // This triggers events in groupsbar.js and contextualinfopanel.js when a selection happens
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
        scope.$on('single group update', function(event, args) {
          // console.log(event, args);
          update(args, args.onlyMembers);
        });

      }
    };
  });