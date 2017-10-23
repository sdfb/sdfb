'use strict';

/**
 * @ngdoc component
 * @name redesign2017App.component:forceLayout
 * @description
 * # forceLayout
 */
angular.module('redesign2017App').directive('forceLayout', ['apiService', '$timeout', '$state', function(apiService, $timeout, $state) {
    return {
      template: '<svg width="100%" height="100%"></svg>',
      restrict: 'E',
      // scope: {
      //   data: '='
      // },
      link: function postLink(scope, element, attrs) {
        console.log('drawing network the first time');

        scope.singleSvg = d3.select(element[0]).select('svg') // Root svg element
          .attr("preserveAspectRatio", "xMinYMin meet")
          .attr("viewBox", function() { return "0 0 "+this.getBoundingClientRect().width+' '+this.getBoundingClientRect().height; })
          .classed("svg-content-responsive", true);
        scope.singleWidth = +scope.singleSvg.node().getBoundingClientRect().width; // Width of viz
        scope.singleHeight = +scope.singleSvg.node().getBoundingClientRect().height; // Height of viz
        scope.singleZoomfactor = 1;
        scope.addedNodes = []; // Nodes user has added to the graph
        scope.addedLinks = []; // Links user has added to the graph
        scope.addedGroups = []; // Groups user has added to the graph
        scope.groupsToggle = false;
        scope.dragNodes = [];
        var simulation,
          sourceId;

          var fisheye = d3.fisheye.circular()
            .radius(75)
            .distortion(2);

          scope.singleSvg.append('rect') // Create container for visualization
            .attr('width', '100%')
            .attr('height', '100%')
            .attr('fill', 'transparent')
            .on('click', function() {
              // Clear selections on nodes and labels
              d3.selectAll('.node, g.label').classed('selected', false);

              // Restore nodes and links to normal opacity. (see toggleClick() below)
              d3.selectAll('.link')
                .classed('faded', false)

              d3.selectAll('.node')
                .classed('faded', false)

              d3.selectAll('.node, .label, .link').classed('not-in-group', false);
              d3.selectAll('.node, .label, .link').classed('in-group', false);
              scope.groupsToggle = false;

              // Must select g.labels since it selects elements in other part of the interface
              d3.selectAll('g.label')
                .classed('hidden', function(d) {
                  if (scope.config.viewMode === 'shared-network') {
                    return (d.distance === 0 || d.distance === 3) ? false : true;
                  } else if (scope.config.viewMode === 'group-force') {
                    var members = scope.data.data.attributes.primary_people;
                    return (members.indexOf(d.id) === -1) ? true : false;
                  } else if (scope.config.viewMode === 'all') {
                    return false;
                  } else {
                    return (d.distance < 2) ? false : true;
                  }
                });

              // reset group bar
              d3.selectAll('.group').classed('active', false);
              d3.selectAll('.group').classed('unactive', false);

              if (scope.$parent.config.contributionMode) {
                var point = d3.mouse(container.node());
                if (scope.config.viewMode === 'all') {
                  scope.addGroupNode(scope.addedGroups, point, scope.updateNetwork);
                } else {
                  scope.addNode(scope.addedNodes, point, scope.updateNetwork);
                }
              }
              // update selction and trigger event for other directives
              scope.currentSelection = {};
              scope.$apply(); // no need to trigger events, just apply
            });

          var container = scope.singleSvg.append('g'); // Create container for nodes and edges

          // Separate groups for links, nodes, and edges
          var link = container.append("g")
            .attr("class", "links")
            .selectAll(".link");

          var node = container.append("g")
            .attr("class", "nodes")
            .selectAll(".node");

          var label = container.append("g")
            .attr("class", "labels")
            .selectAll(".label");

        function getNodesAndLinks(json) {
          var nodes = json.included, // All people data
              links = []; // All relationship data, fill array belowre

          // Populate links array from JSON
          json.data.attributes.connections.forEach(function(c) {
            // Retain ID and type from level above in JSON
            c.attributes.id = c.id;
            c.attributes.type = c.type;
            links.push(c.attributes);
          });

          return [nodes, links];
        }

        function generateNetwork(json) {
        sourceId = json.data.attributes.primary_people; // ID of searched node (Bacon in sample data)




        var nodesAndLinks = getNodesAndLinks(json),
            nodes = nodesAndLinks[0],
            links = nodesAndLinks[1];





        //              //
        //  SIMULATION  //
        //              //

        simulation = d3.forceSimulation(nodes)
          .force("center", d3.forceCenter(scope.singleWidth / 2, scope.singleHeight / 2)) // Keep graph from floating off-screen
          .force("charge", d3.forceManyBody().strength(-100)) // Charge force works as gravity
          .force("link", d3.forceLink(links).id(function(d) { return d.id; }).iterations(2)) //Link force accounts for link distance
          .force("collide", d3.forceCollide().iterations(0)) // in the tick function will be evaluated the moment in which turn on the anticollision (iterations > 1)
          // general force settings
          .alpha(1)
          .alphaDecay(0.05)
          .on("tick", ticked);

        }

        scope.updateNetwork = function(json) {

          /* The main update function draws the all of the elements of the visualization
          and keeps them up to date using the D3 general update pattern. Takes as variables ranges
          for confidence and date, as well as a complexity value and a layout type (force or concentric) */

          var  confidenceMin = scope.config.confidenceMin, // Minimum edge weight (default 60)
            confidenceMax = scope.config.confidenceMax, // Maximum edge weight (default 100)
            dateMin = scope.config.dateMin, // Minimum date range (source's birthdate)
            dateMax = scope.config.dateMax, // Maximum date range (source's death date)
            complexity = scope.config.networkComplexity, // Visual density (default 2)
            endTime, // Length of viz transition
            toggle = 0, // Toggle for ego networks on click (see toggleClick())
            oldLayout = 'individual-force'; // Keep track of whether the layout has changed

          var layout = json.layout;

          var nodesAndLinks = getNodesAndLinks(json),
              nodes = nodesAndLinks[0],
              links = nodesAndLinks[1];

          var startTime = d3.now();
          simulation.on("end", function() {
            var endTime = d3.now();
            console.log('Spatialization completed in', (endTime - startTime) / 1000, 'sec.');
          })

          console.log('force layout update function');
          // Find the links that are within date and confidence ranges.
          var thresholdLinks = links.filter(function(d) {
            if (d.weight >= confidenceMin && d.weight <= confidenceMax && parseInt(d.start_year) <= dateMax && parseInt(d.end_year) >= dateMin) {
              return d;
            };
          });

          if (scope.config.viewMode === 'individual-force' || scope.config.viewMode === 'individual-concentric') {
            var newData = parseIndComplexity(thresholdLinks, complexity); // Use links in complexity function, which return nodes and links.
          } else if (scope.config.viewMode === 'shared-network') {
            var sources = json.data.attributes.primary_people;
            var newData = parseSharedComplexity(thresholdLinks, complexity, sources);
          } else if (scope.config.viewMode === 'group-force') {
            var members = json.data.attributes.primary_people;
            var newData = parseGroupComplexity(json, scope.config.onlyMembers);
          } else {
            var nodes = json.included;
            var links = [];
            json.data.attributes.connections.forEach(function(l) {
              links.push({
                'type': l.type,
                'source': l.attributes.source,
                'target': l.attributes.target,
                'weight': l.attributes.weight
              })
            });
            var newData = [nodes, links];
          }

          var newNodes = newData[0];
          scope.dragNodes = newNodes
          var newLinks = newData[1];

          scope.addedNodes.forEach(function(a) { newNodes.push(a); });
          if (scope.config.viewMode === 'all') {
            scope.addedGroups.forEach(function(a) { newNodes.push(a); });
          }
          scope.addedLinks.forEach(function(a) { newLinks.push(a); });

          if (scope.config.viewMode == 'individual-concentric') {
            // For concentric layout, set fixed positions according to degree
            newNodes.forEach(function(d) {
              if (d.distance == 0) { // Set source node to center of view
                d.fx = scope.singleWidth / 2;
                d.fy = scope.singleHeight / 2;
              }
            })

            var oneDegreeNodes = newNodes.filter(function(d) { if (d.distance == 1) { return d; } });
            positionCircle(oneDegreeNodes, 200); // Put 1-degree nodes in circle of radius 200

            var twoDegreeNodes = newNodes.filter(function(d) { if (d.distance == 2) { return d; } });
            positionCircle(twoDegreeNodes, 500); // Put 2-degree nodes in circle of radius 500
          } else if (scope.config.viewMode === 'shared-network') {
            newNodes.forEach( function(d) {
              if (d.id == sources[0]) {
                d.fx = scope.singleWidth/8;
                d.fy = scope.singleHeight/2;
              }
              if (d.id == sources[1]) {
                d.fx = scope.singleWidth * (7/8)
                d.fy = scope.singleHeight/2
              }
            })
          } else {
            // For force layout, set fixed positions to null (undoes circle positioning)
            nodes.forEach(function(d) {
              d.fx = null;
              d.fy = null;
            });
          }



          //          //
          //  LINKS   //
          //          //

          // Sort "newlinks" array so to have the "altered" links at the end and display them on "foreground"
          newLinks.sort(function(a, b) {
            if (a.altered) {
              return 1
            }
          });

          // Data join with only new links from parseComplexity()
          link = link.data(newLinks, function(d) {
            return d.source.id + ', ' + d.target.id;
          });

          var linkEnter = link.enter().append('path') // Create enter variable for general update pattern

          link.exit().remove(); // Remove exiting links

          link = linkEnter.merge(link) // Merge new links
            .attr('class', 'link')
            .classed('altered', function(d) { // Style if link has been "altered" by a person
              return d.altered ? true : false;
            })
            .classed('new', function(d) {
              return d.new ? true : false;
            })
            .attr("stroke-width", function(d) {
              if (scope.config.viewMode === 'all') {
                var sizeEdge = d3.scaleLinear()
                  .range([1, 10]);
                var minWeight = d3.min(newLinks, function(d) { return d.weight });
                var maxWeight = d3.max(newLinks, function(d) { return d.weight });
                sizeEdge.domain([minWeight, maxWeight]);
                return sizeEdge(d.weight)
              }
            })
            .on('click', function(d) { // Toggle link on click
              toggleClick(d, newLinks);
            });










          //          //
          //  NODES   //
          //          //

          // Data join with only new nodes from parseComplexity()
          node = node.data(newNodes, function(d) {
            return d.id;
          })

          if (scope.config.viewMode === 'all') {
            var sizeScale = d3.scaleLinear()
              .range([8, 30]);

            var maxDegree = d3.max(newNodes, function(d) { return d.attributes.degree; });
            var minDegree = d3.min(newNodes, function(d) { return d.attributes.degree; });
            sizeScale.domain([minDegree, maxDegree]);
            node.exit().remove();
            node = node.enter().append("rect")
              .merge(node)
              .attr("class", "node")
              .attr("width", function(d) { return (2 * sizeScale(d.attributes.degree)) / Math.sqrt(2); })
              .attr("height", function(d) { return (2 * sizeScale(d.attributes.degree)) / Math.sqrt(2); })
              .attr("rx", 2)
              .attr("ry", 2)
              .classed("degree7", function(d) { return d.distance === 7; })
              .classed("all", function (d) { return d.distance !== 7; })
              .on("click", function(d) {
                // console.log(d, d.attributes.name)
                // Toggle ego networks on click of node
                toggleClick(d, newLinks, this);
              })
              .on('dblclick', function(d){
                if (d.id !== 0) {
                  $state.go('home.visualization', {ids: d.id, type: 'network'});
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
                d3.selectAll('g.label').each(function(e) {
                  if (e.id == d.id) {
                    d3.select(this).classed('temporary-unhidden', true);
                  }
                })
                // // sort elements so to bring the hovered one on top and make it readable.
                scope.singleSvg.selectAll("g.label").each(function(e, i) {
                  if (d == e) {
                    var myElement = this;
                    d3.select(myElement).remove();
                    d3.select('.labels').node().appendChild(myElement);
                  }
                })
              })
              .on('mouseleave', function(d) {
                d3.selectAll('g.label').each(function(e) {
                  if (e.id == d.id) {
                    d3.select(this).classed('temporary-unhidden', false);
                  }
                })
              })
              .call(d3.drag()
                .on("start", dragstarted)
                .on("drag", dragged)
                .on("end", dragended));
          } else {
            var nodeEnter = node.enter().append('circle'); // Create enter variable for general update pattern


            node.exit().remove(); // Remove exiting nodes

            node = nodeEnter.merge(node) // Merge new nodes
              .attr('class', function(d) { // Class by degree of distance
                if (scope.config.viewMode == 'shared-network') {
                  if (d.distance === 0) {
                    return 'node degree' + 3
                  }
                  else if (d.distance === 1) {
                    return 'node degree' + 4
                  }
                  else if (d.distance === 2) {
                    return 'node degree' + 1
                  }
                  else if (d.distance === 3) {
                    return 'node degree' + 0
                  }
                  else if (d.distance === 7) {
                    return 'node degree' + 7
                  }
                } else if (scope.config.viewMode === 'group-force') {
                  if (members.indexOf(d.id) === -1) {
                    if (d.distance === 7) { return 'node degree7'; }
                    else { return 'node not-member'; }
                  }
                  else { return 'node member'; };
                } else {
                  return 'node degree' + d.distance
                }
              })
              .attr('id', function(d) { // Assign ID number
                return "n" + d.id.toString();
              })
              .attr('r', function(d) { // Size nodes by degree of distance
                if (scope.config.viewMode == 'shared-network') {
                  if (d.distance === 0 || d.distance === 3) {
                    return 25;
                  } else if (d.distance === 2) {
                    return 12.5;
                  } else {
                    return 6.25;
                  }
                } else if (scope.config.viewMode === 'group-force') {
                  if (members.indexOf(d.id) === -1) { return 6.25; }
                  else { return 12.5; };
                } else {
                  if (d.distance == 0) {
                    return 25;
                  } else if (d.distance == 1) {
                    return 12.5;
                  } else {
                    return 6.25;
                  }
                }
              })
              .on('click', function(d) {
                // Toggle ego networks on click of node

                toggleClick(d, newLinks, this);
              })
              .on('dblclick', function(d){
                $state.go('home.visualization', {ids: d.id});
              })
              // On hover, display label
              .on('mouseenter', function(d) {
                d3.selectAll('g.label').each(function(e) {
                  if (e.id == d.id) {
                    d3.select(this)
                      .classed('temporary-unhidden', true);
                  }
                })
                // sort elements so to bring the hovered one on top and make it readable.
                scope.singleSvg.selectAll("g.label").each(function(e, i) {
                  if (d == e) {
                    var myElement = this;
                    d3.select(myElement).remove();
                    d3.select('.labels').node().appendChild(myElement);
                  }
                })
              })
              .on('mouseleave', function(d) {
                d3.selectAll('g.label').each(function(e) {
                  if (e.id == d.id) {
                    d3.select(this).classed('temporary-unhidden', false);
                  }
                })
              })
              .call(d3.drag()
                .on("start", dragstarted)
                .on("drag", dragged)
                .on("end", dragended));
            }















          //          //
          //  LABELS  //
          //          //

          // Data join with only new nodes from parseComplexity()
          label = label.data(newNodes, function(d) {
            return d.id;
          });

          label.exit().remove(); // Remove exiting labels

          // Create group for the label but define the position later
          var labelEnter = label.enter().append('g')
            .attr("class", function(d) {
              if (scope.config.viewMode === 'shared-network') {
                return (d.distance === 0 || d.distance === 3) ? 'label' : 'label hidden';
              } else if (scope.config.viewMode === 'group-force') {
                return (members.indexOf(d.id) === -1) ? 'label hidden' : 'label';
              } else if (scope.config.viewMode === 'all') {
                return 'label';
              }{
                return (d.distance < 2) ? 'label' : 'label hidden';
              }
            })
            .attr('id', function(d) { // Assign ID number
              return "l" + d.id.toString();
            });

          label.selectAll('*').remove();

          label = labelEnter.merge(label); // Merge all entering labels

          label.append('rect') // a placeholder to be reworked later

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

          simulation.alphaTarget(0).restart();

          oldLayout = layout;

        }

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

          scope.showNewLink(d, scope.dragNodes);

        }

        function dragstarted(d) {

          scope.dragNodes.forEach(function(n) {
            n.fx = n.x;
            n.fy = n.y;
          });
          if (!d3.event.active) simulation.alphaTarget(0.3).restart();
        }

        function dragended(d) {

          // var nodes = scope.data.included;
          if (scope.$parent.config.contributionMode) {
            scope.createNewLink(d, scope.dragNodes, scope.addedLinks);
            scope.endGroupEvents();
            scope.updateNetwork(scope.data);

          }
        }

        // Move the circle with the mouse, until the the user clicks
        function mousemove() {
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



        // The function accepts a new variable (array of sources)
        function parseSharedComplexity(thresholdLinks, complexity, sources) {

          var sourceId1 = sources[0]
          var sourceId2 = sources[1]
          var oneDegreeNodes = [];
          thresholdLinks.forEach( function (l) {
            if (l.source.id == sourceId1 || l.source.id == sourceId2 || l.target.id == sourceId1 || l.target.id == sourceId2) {
              oneDegreeNodes.push(l.target); oneDegreeNodes.push(l.source);
            }
          })
          oneDegreeNodes = Array.from(new Set(oneDegreeNodes));

          var newLinks = thresholdLinks.filter(function(l) { if (oneDegreeNodes.indexOf(l.target) != -1 && oneDegreeNodes.indexOf(l.source) != -1) {return l; }; });

          var sourceOneNeighbors = [];
          var sourceTwoNeighbors = [];
          newLinks.forEach(function(l){
            if (l.source.id == sourceId1) {sourceOneNeighbors.push(l.target);}
            else if (l.target.id == sourceId1) {sourceOneNeighbors.push(l.source);}
            else if (l.source.id == sourceId2) {sourceTwoNeighbors.push(l.target);}
            else if (l.target.id == sourceId2) {sourceTwoNeighbors.push(l.source);}
          })
          oneDegreeNodes.forEach(function(d){
            d.distance = null;
            if (d.id == sourceId1 || d.id == sourceId2) { d.distance = 0; }
            else if (sourceOneNeighbors.indexOf(d) != -1 && sourceTwoNeighbors.indexOf(d) != -1) {d.distance = 3;}
            else if (sourceOneNeighbors.indexOf(d) != -1) {
              newLinks.forEach(function(l) {
                if ((l.source.id == d.id && sourceTwoNeighbors.indexOf(l.target) != -1) || (l.target.id == d.id && sourceTwoNeighbors.indexOf(l.source) != -1)) {
                  d.distance = 2;
                }
              });
            }
            else if (sourceTwoNeighbors.indexOf(d) != -1) {
              newLinks.forEach(function(l) {
                if ((l.source.id == d.id && sourceOneNeighbors.indexOf(l.target) != -1) || (l.target.id == d.id && sourceOneNeighbors.indexOf(l.source) != -1)) {
                  d.distance = 2;
                }
              });
            }
            // else if (d.distance == null) {d.distance = 1;}
          });

          oneDegreeNodes.forEach(function(d) {
            if (d.distance == null) {d.distance = 1;}
          });

          var newNodes = oneDegreeNodes;

          if (complexity === "direct_connections") {
            newNodes = newNodes.filter(function(d) {return d.distance === 0 || d.distance === 2 || d.distance === 3; });
            newLinks = newLinks.filter(function(l) {
              return newNodes.indexOf(l.source) != -1 && newNodes.indexOf(l.target) != -1;
            });
          }
          return [newNodes, newLinks];

        }


        function parseGroupComplexity(json, onlyMembers) {
          var members = json.data.attributes.primary_people;
          if (onlyMembers === false) {
            var links = [];
            json.data.attributes.connections.forEach(function (l) {
              l.attributes.id = l.id;
              links.push(l.attributes);
            });
            var newData = [json.included, links];
          } else if (onlyMembers === true) {
            var nodes = json.included.filter(function(n) { return members.indexOf(n.id) !== -1; });
            var links = [];
            json.data.attributes.connections.forEach(function (l) {
              l.attributes.id = l.id;
              if (members.indexOf(l.attributes.source.id) !== -1 && members.indexOf(l.attributes.target.id) !== -1) {
                links.push(l.attributes);
              }
            });
            var newData = [nodes, links];
          }
          return newData;
        }

        // VISUAL DENSITY PARSER
        function parseIndComplexity(thresholdLinks, complexity) {
          /* Given a list of links already limited according to date and confidence
          range, return nodes and links according to given complexity (visual density)
          measure. */

          // Find current 1-degree nodes
          var oneDegreeNodes = [];
          thresholdLinks.forEach(function(l) {
            if (l.source.id == sourceId || l.target.id == sourceId) {
              oneDegreeNodes.push(l.source);
              oneDegreeNodes.push(l.target);
            };
          });
          oneDegreeNodes = Array.from(new Set(oneDegreeNodes));

          // Find current 2-degree nodes (anything not in 1-degree list and not source)
          var twoDegreeNodes = [];
          thresholdLinks.forEach(function(l) {
            if (oneDegreeNodes.indexOf(l.source) != -1 && oneDegreeNodes.indexOf(l.target) == -1) {
              twoDegreeNodes.push(l.target);
            } else if (oneDegreeNodes.indexOf(l.target) != -1 && oneDegreeNodes.indexOf(l.source) == -1) {
              twoDegreeNodes.push(l.source);
            };
          });
          twoDegreeNodes = Array.from(new Set(twoDegreeNodes));

          var allNodes = oneDegreeNodes.concat(twoDegreeNodes); // Get full list of nodes at threshold

          // Assign appropriate distance variable for source, 1-, and 2-degree nodes
          allNodes.forEach(function(d) {
            if (d.id == sourceId) {
              d.distance = 0;
            } else if (oneDegreeNodes.indexOf(d) != -1) {
              d.distance = 1;
            } else {
              d.distance = 2;
            }
          });

          // For Visual Density of 1, get only source and 1-degree nodes
          // Only links from source to other nodes
          if (complexity == '1') {
            var newLinks = thresholdLinks.filter(function(l) {
              if (l.source.id == sourceId || l.target.id == sourceId) { //Link must have sourceId as source or target
                return l;
              }
            })
            return [oneDegreeNodes, newLinks];
          }

          // For Visual Density of 1.5, get source and 1-degree nodes
          // All links among these nodes
          if (complexity == '1.5') {
            var newLinks = thresholdLinks.filter(function(l) {
              if (oneDegreeNodes.indexOf(l.source) != -1 && oneDegreeNodes.indexOf(l.target) != -1) { //Link must have 1-degree node as source and target
                return l;
              }
            });
            return [oneDegreeNodes, newLinks];
          }

          /* For Visual Density of 1.5, get source, 1-degree, and
          all 2-degree nodes that have links to **at least two** 1-degree
          nodes. Plus all links among these nodes. */
          if (complexity == '1.75') {
            var newNodes = [];
            twoDegreeNodes.forEach(function(d) {
              var count = 0;
              thresholdLinks.forEach(function(l) {
                // Count links with a source or target in 1-degree node array
                if (l.source == d && oneDegreeNodes.indexOf(l.target) != -1) {
                  count += 1;
                } else if (l.target == d && oneDegreeNodes.indexOf(l.source) != -1) {
                  count += 1;
                }
              });

              // Return only 2-degree nodes with count greater than 2
              if (count >= 2) {
                newNodes.push(d);
              }
            });

            // Get 1-degree nodes, add to array, and get all links
            newNodes = oneDegreeNodes.concat(newNodes);
            newLinks = thresholdLinks.filter(function(l) {
              if (newNodes.indexOf(l.source) != -1 && newNodes.indexOf(l.target) != -1) { //Link must have node in array as source and target
                return l;
              }
            });
            newLinks = newLinks.filter(function(l) {
              return oneDegreeNodes.indexOf(l.source) !== -1 || oneDegreeNodes.indexOf(l.target) !== -1;
            })
            return [newNodes, newLinks];
          }

          /* For Visual Density of 2, get all nodes, plus all links among
          1-degree nodes and any links from 2-degree nodes to 1-degree nodes.
          (But NOT links between 2-degree nodes.) */
          if (complexity == '2') {
            newLinks = thresholdLinks.filter(function(l) {
              if (oneDegreeNodes.indexOf(l.source) != -1 || oneDegreeNodes.indexOf(l.target) != -1) { //Link must have 1-degree node as source or target
                return l;
              }
            });
            return [allNodes, newLinks];
          }

          // For Visual Density of 2.5, get all available nodes and links.
          if (complexity == '2.5') {
            var newLinks = thresholdLinks.filter(function(l) {
              if (allNodes.indexOf(l.source) != -1 && allNodes.indexOf(l.target) != -1) {
                return l;
              }
            });
            return [allNodes, newLinks];
          }
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

          if (d.type == "person" || d.type == "group") { //Handler for when a node is clicked

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

            if (d.type === "person") {
              // This triggers events in groupsbar.js and contextualinfopanel.js when a selection happens
              apiService.getPeople(d.id).then(function (result) {
                scope.currentSelection = result.data[0];
                $timeout(function(){
                  scope.$broadcast('selectionUpdated', scope.currentSelection);
                });
              });
              if (scope.config.contributionMode) {
                scope.$apply(function() {
                  scope.groupAssign.person.name = d.attributes.name;
                  scope.groupAssign.person.id = d.id;
                  scope.groupAssignClosed = false;
                  scope.addLinkClosed = true;
                  scope.legendClosed = true;
                  scope.filtersClosed = true;
                  scope.peopleFinderClosed = true;
                });
              }
            } else {
              apiService.getGroups(d.id).then(function (result) {
                scope.currentSelection = result.data;
                scope.currentSelection.type = 'group';
                $timeout(function(){
                  scope.$broadcast('selectionUpdated', scope.currentSelection);
                });
              });
            }

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
            apiService.getRelationship(d.id).then(function (result) {
              scope.currentSelection = result.data[0];
              scope.currentSelection.source = d.source;
              scope.currentSelection.target = d.target;
              $timeout(function(){
                scope.$broadcast('selectionUpdated', scope.currentSelection);
              });
            });
          }

        }


        scope.singleZoom = d3.zoom(); // Create a single zoom function
        // Call zoom for scope.singleSvg container.
        scope.singleSvg.call(scope.singleZoom.on('zoom', zoomed)).on("dblclick.zoom", null); // See zoomed() below


        // Zooming function translates the size of the scope.singleSvg container on wheel scroll.
        function zoomed() {
          container.attr("transform", "translate(" + d3.event.transform.x + ", " + d3.event.transform.y + ") scale(" + d3.event.transform.k + ")");
        }

        // Tick function for positioning links, node, and edges on each iteration of
        // the force simulation
        function ticked() {
          link // Since we're using a path instead of a line, links only need "d" attr
            .attr("d", function(d) {
              var dx = d.target.x - d.source.x,
                dy = d.target.y - d.source.y,
                dr = Math.sqrt(dx * dx + dy * dy);
              return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
            });

          if (scope.config.viewMode === 'all') {
            var nodes = scope.data.included;
            var sizeScale = d3.scaleLinear()
              .range([8, 30]);

            var maxDegree = d3.max(nodes, function(d) { return d.attributes.degree; });
            var minDegree = d3.min(nodes, function(d) { return d.attributes.degree; });
            sizeScale.domain([minDegree, maxDegree]);
            node.attr("x", function(d) { return d.x - sizeScale(d.attributes.degree) / Math.sqrt(2) })
              .attr("y", function(d) { return d.y - sizeScale(d.attributes.degree) / Math.sqrt(2) })
              .style("transform-origin", function(d) {
                var translationValue = d.x + 'px ' + d.y + 'px';
                return translationValue;
              })
          } else {
            node // Take x and y values from data
              .attr("cx", function(d) { return d.x; })
              .attr("cy", function(d) { return d.y; });
          }

          label // Position labels in center of nodes
            .attr("transform", function(d) {
              return "translate(" + (d.x) + "," + (d.y + 2.5) + ")"
            })

          if (simulation.alpha() < 0.005 && simulation.force("collide").iterations() == 0) {
            simulation.force("collide").iterations(1).radius(function(d) { // Collision detection
              if (scope.config.viewMode === 'shared-network') {
                if (d.distance === 0 || d.distance === 3) { // Account for larger source node
                  return 50 / 2 + 1;
                } else if (d.distance === 2) {
                  return 25 / 2 + 1;
                } else {
                  return 12.5 / 2 + 1;
                }
              } else {
                if (d.distance == 0) { // Account for larger source node
                  return 50 / 2 + 1;
                } else if (d.distance == 1) {
                  return 25 / 2 + 1;
                } else if (d.distance == 2) {
                  return 12.5 / 2 + 1;
                }
              }
            });
          }

        }


        function positionCircle(nodelist, r) {
          /* For concentric layout, with a given node array
          and a radius value, use trig to position the nodes in a circle */
          var angle = 2*Math.PI*r / nodelist.length; // Get angle based on number of nodes
          nodelist.forEach(function(n, i) {
            n.fx = r * Math.cos(2 * Math.PI * i / nodelist.length) + (scope.singleWidth / 2); // Fix x coordinate
            n.fy = r * Math.sin(2 * Math.PI * i / nodelist.length) + (scope.singleHeight / 2); // Fix y coordinate
          });
        }

        scope.$watch('$stateParams.ids', function(newValue, oldValue) {
          if (scope.config.viewMode !== 'group-timeline') {
            generateNetwork(scope.data);
            if (scope.config.viewMode !== 'all' && scope.config.viewMode !== 'group-force') {
              scope.data4groups(scope.data);
            }
            // scope.centerNetwork();
          }
        }, true);

        scope.$watchCollection('data', function(newValue, oldValue) {
          if (scope.config.viewMode !== 'group-timeline') {
            scope.updateNetwork(newValue);
          }
        }, true);

        scope.$watch('config.onlyMembers', function(newValue, oldValue) {
          if (scope.config.viewMode === 'group-force') {
            scope.updateNetwork(scope.data);
          }
        }, true);

        scope.$watch('config.viewMode', function(newValue, oldValue) {
          if (scope.config.viewMode !== 'group-timeline') {
            scope.updateNetwork(scope.data);
            simulation.alpha(1);
          }
        }, true);


      }
    }
  }]);
