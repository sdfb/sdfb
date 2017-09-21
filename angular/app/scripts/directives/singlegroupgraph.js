'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:singleGroupGraph
 * @description
 * # singleGroupGraph
 */
angular.module('redesign2017App')
  .directive('singleGroupGraph', ['apiService', '$timeout', function(apiService, $timeout) {
    return {
      template: '<svg id="single-group" width="100%" height="100%"></svg>',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {

        scope.groupSvg = d3.select(element[0]).select('svg#single-group'); // Root svg element
        scope.groupWidth = +scope.groupSvg.node().getBoundingClientRect().width; // Width of viz
        scope.groupHeight = +scope.groupSvg.node().getBoundingClientRect().height; // Height of viz
        scope.groupZoomfactor = 1;
        scope.addedGroupNodes = []; // Nodes user has added to the graph
        scope.addedGroupLinks = []; // Links user has added to the graph

        var chartWidth = scope.groupWidth;
        var nodes = [];
        var links = [];
        var members = [];
        var simulation;



        var cursor = scope.groupSvg.append("circle")
          .attr("r", 12.5)
          .attr("fill", "none")
          .attr("stroke", "orange")
          .attr("stroke-width", 1.5)
          .attr('stroke-dasharray', 5,5)
          .attr("opacity", 0)//function() {
            // if (scope.config.contributionMode) {return 1;} else {return 0;}
          // })
          .attr("transform", "translate(-100,-100)")
          .attr("class", "cursor");

        scope.groupSvg.append("rect")
          .attr("width", scope.groupWidth)
          .attr("height", scope.groupHeight)
          .style("fill", "none")
          .style("pointer-events", "all")
          // .call(zoom
            // .scaleExtent([1 / 2, 4])
            // .on("zoom", zoomed))
          .on("click", function() {
            d3.selectAll('#single-group .node, #single-group .link').classed('faded', false);
            d3.selectAll('#single-group g.label').classed("hidden", function(d, i) {
              return (d3.select('#n'+d.id).classed('member') === true) ? false : true;
            });
            // update selction and trigger event for other directives
            scope.currentSelection = {};
            scope.$apply(); // no need to trigger events, just apply

            if (scope.config.contributionMode) {
              var point = d3.mouse(scope.groupSvg.node());
              scope.addNode(scope.addedGroupNodes, point, scope.updateGroupNetwork);
            }
          })
          .on('mousemove', mousemove);

        scope.groupZoom = d3.zoom(); // Create a single zoom function
        // Call zoom for svg container.
        scope.groupSvg.call(scope.groupZoom.on('zoom', zoomed)); //.on("dblclick.zoom", null); // See zoomed() below

        function zoomed() {
          g.attr("transform", "translate(" + d3.event.transform.x + ", " + d3.event.transform.y + ") scale(" + d3.event.transform.k + ")");
        }

        var g = scope.groupSvg.append("g").attr("transform", "translate(" + (scope.groupWidth / 2) * 0 + "," + (scope.groupHeight / 2) * 0 + ")"),
          link = g.append("g").selectAll(".link"),
          node = g.append("g").selectAll(".node");
        var label = g.append("g").attr("class", "labels").selectAll(".label");

        var sizeScale = d3.scaleLinear()
          .range([8, 30]);

        var sizeEdge = d3.scaleLinear()
          .range([1, 10]);

        scope.updateGroupNetwork = function(json, onlyMembers) {
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
                'weight': l.attributes.weight,
                'id': l.id
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
                'weight': l.attributes.weight,
                'id': l.id
              })
            })
          }

          var maxDegree = d3.max(nodes, function(d) { return d.attributes.degree; });
          var minDegree = d3.min(nodes, function(d) { return d.attributes.degree; });
          sizeScale.domain([minDegree, maxDegree]);

          var minWeight = d3.min(links, function(d) { return d.weight });
          var maxWeight = d3.max(links, function(d) { return d.weight });

          sizeEdge.domain([minWeight, maxWeight]);

          simulation = d3.forceSimulation(nodes)
            .force("center", d3.forceCenter(scope.groupWidth / 2, scope.groupHeight / 2))
            // .force("x", d3.forceX(scope.groupWidth / 2))
            // .force("y", d3.forceY(scope.groupHeight / 2))
            .force("charge", d3.forceManyBody().strength(-100))
            .force("link", d3.forceLink(links).id(function(d) { return d.id }).iterations(1))
            .force("collide", d3.forceCollide().iterations(0))
            // .force("collide", d3.forceCollide(function(d) { return sizeScale(d.attributes.degree) + 1 }).iterations(0))
            .alpha(1)
            .alphaDecay(0.05)
            .on("tick", ticked);

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

            scope.addedGroupNodes.forEach(function(a) { nodes.push(a); });
            scope.addedGroupLinks.forEach(function(a) { links.push(a); });

            node = node.data(nodes, function(d) { return d.id; });
            node.exit().remove();
            node = node.enter().append("circle")
              .merge(node)
              .attr("class", "node")
              .classed('member', function(d) {
                return members.filter(function(e) { return e == d.id; }).length > 0;
              })
              .classed('new', function(d) {
                return d.distance === 7;
              })
              .attr('id', function(d) { // Assign ID number
                return "n" + d.id.toString();
              })
              .attr("r", function(d) {
                if (members.indexOf(d.id) === -1) { return 6.25; }
                else { return 12.5; };
              })
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
                scope.groupSvg.selectAll("single-group-graph g.label").each(function(e, i) {
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
              })
              .call(d3.drag()
                .on("start", dragstarted)
                .on("drag", dragged)
                .on("end", dragended));



            // Apply the general update pattern to the links.
            link = link.data(links, function(d) { return d.source.id + "-" + d.target.id; });
            link.exit().remove();
            link = link.enter().append("path")
              .merge(link)
              .attr("class", "link")
              .classed('new', function(d) {
                return d.new ? true : false;
              })
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
                return (d3.select('#n'+d.id).classed('member') === true) ? false : true;
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
          // simulation.nodes(nodes);
          // simulation.force("link").links(links);
          simulation.alphaTarget(0).restart();
          simulation.on("end", function() {
            var endTime = d3.now();
            console.log('Spatialization completed in', (endTime - startTime) / 1000, 'sec.');
          })
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

        // Code for adding links adapted from: https://bl.ocks.org/emeeks/f2f6883ac7c965d09b90

        function dragged(d) {
          if (d.distance === 7) {
            d.x = d3.event.x;
            d.y = d3.event.y;
          }
          else {
            d.fx = d3.event.x;
            d.fy = d3.event.y;
          }

          // var nodeOne = this;
          // var foundOverlap = false;



          // if (scope.config.contributionMode) {
          //   fisheye.focus(d3.mouse(this));
          //
          //   node.each(function(f) { f.fisheye = fisheye(f); })
          //       .attr("cx", function(f) { return f.fisheye.x; })
          //       .attr("cy", function(f) { return f.fisheye.y; })
          //       .attr("r", function(f) {
          //         if (f.distance == 0) {
          //           return 25 * f.fisheye.z;
          //         } else if (f.distance == 1) {
          //           return 12.5 * f.fisheye.z;
          //         } else {
          //           return 6.25 * f.fisheye.z;
          //         }
          //       });
          //
          //   link.attr("d", function(f) {
          //     var dx = f.target.fisheye.x - f.source.fisheye.x,
          //       dy = f.target.fisheye.y - f.source.fisheye.y,
          //       dr = Math.sqrt(dx * dx + dy * dy);
          //     return "M" + f.source.fisheye.x + "," + f.source.fisheye.y + "A" + dr + "," + dr + " 0 0,1 " + f.target.fisheye.x + "," + f.target.fisheye.y;
          //   });
          // }
          scope.showGroupAssign(d);

          scope.showNewLink(d);

        }

        function dragstarted(d) {

          cursor.attr("opacity", 0);

          var nodes = scope.data.included;
          nodes.forEach(function(n) {
            n.fx = n.x;
            n.fy = n.y;
          });
          if (!d3.event.active) simulation.alphaTarget(0.3).restart();
        }

        function dragended(d) {

          var nodes = scope.data.included;
          if (scope.config.contributionMode) {
            cursor.attr("opacity", 1);
            scope.createNewLink(d, nodes, scope.addedGroupLinks);
            scope.updateGroupNetwork(scope.data, scope.data.onlyMembers);

          }
        }

        // Move the circle with the mouse, until the the user clicks
        function mousemove() {
          cursor.attr("transform", "translate(" + d3.mouse(scope.groupSvg.node()) + ")");
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
          if (simulation.alpha() < 0.005 && simulation.force("collide").iterations() == 0) {
            simulation.force("collide").iterations(1).radius(function(d) {
              if (members.indexOf(d.id) === -1) { return 6.25; }
              else { return 12.5; };
            });
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
            // This triggers events in groupsbar.js and contextualinfopanel.js when a selection happens
            // scope.currentSelection = d;
            apiService.getPeople(d.id).then(function (result) {
              // console.log(result);
              scope.currentSelection = result.data[0];
              // console.log(scope.currentSelection);
              $timeout(function(){
                scope.$broadcast('selectionUpdated', scope.currentSelection);
              });
            });
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
            // scope.currentSelection = d;
            // scope.$broadcast('selectionUpdated', scope.currentSelection);
            console.log(d);
            apiService.getRelationship(d.id).then(function (result) {
              // console.log(result);
              scope.currentSelection = result.data[0];
              scope.currentSelection.source = d.source;
              scope.currentSelection.target = d.target;
              // console.log(scope.currentSelection);
              $timeout(function(){
                scope.$broadcast('selectionUpdated', scope.currentSelection);
              });
            });
          }

        }

        // action triggered from the controller
        scope.$on('single group update', function(event, args) {
          // console.log(event, args);
          scope.data = args;
          scope.updateGroupNetwork(args, args.onlyMembers);
        });

      }
    };
  }]);
