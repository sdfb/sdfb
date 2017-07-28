'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:sharedNetwork
 * @description
 * # sharedNetwork
 */
angular.module('redesign2017App')
  .directive('sharedNetwork', function(apiService) {
    return {
      template: '<svg id="shared-network" width="100%" height="100%"></svg>',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {

        var svg = d3.select(element[0]).select('svg#shared-network'),
          width = +svg.node().getBoundingClientRect().width,
          height = +svg.node().getBoundingClientRect().height

        // The function accepts a new variable (array of sources)
        function parseComplexity(thresholdLinks, complexity, sources) {
          
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

          return [newNodes, newLinks];

        }



        function updateSharedNetwork(json) {

          var nodes = json.included;
          var links = [];
          // Populate links array from JSON
          json.data.attributes.connections.forEach(function(c) {
            // Retain ID and type from level above in JSON
            c.attributes.id = c.id;
            c.attributes.type = c.type;
            links.push(c.attributes);
          });

          var simulation = d3.forceSimulation()
            .force("link", d3.forceLink().id(function(d) {
              return d.id;
            })) //Link force accounts for link distance
            .force("charge", d3.forceManyBody().strength(-75)) // Charge force works as gravity
            .force("center", d3.forceCenter(width / 2, height / 2)) // Keep graph from floating off-screen
            .force("collide", d3.forceCollide().radius(20)); //function(d) { // Collision detection
            //   if (d.id in sources) { // Account for larger source node
            //     return 26;
            //   } else {
            //     return 13;
            //   }
            // }));

          simulation
            .nodes(nodes)
            .on("tick", ticked);

          simulation.force("link")
            .links(links);



          // console.log(links);

          // links.forEach(function(l) {
          //   var thisSource = json.included.filter(function(n) {
          //     return l.source == n.id;
          //   })
          //   l.source = thisSource[0];
          //   var thisTarget = json.included.filter(function(n) {
          //     return l.target == n.id;
          //   })
          //   l.target = thisTarget[0];
          // })

          var confidenceMin = scope.config.confidenceMin,
            confidenceMax = scope.config.confidenceMax,
            dateMin = scope.config.dateMin,
            dateMax = scope.config.dateMax,
            complexity = scope.config.networkComplexity,
            sources = json.data.attributes.primary_people;


          svg.append('rect') // Create container for visualization
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

            // Must select g.labels since it selects elements in other part of the interface
            d3.selectAll('g.label')
              .classed('hidden', function(d) {
                return (d.distance === 0) ? false : true;
              });

            // reset group bar
            d3.selectAll('.group').classed('active', false);
            d3.selectAll('.group').classed('unactive', false);

            // update selction and trigger event for other directives
            scope.currentSelection = {};
            scope.$apply(); // no need to trigger events, just apply
          });

          var thresholdLinks = links.filter(function(d) {
            return d.weight >= confidenceMin && d.weight <= confidenceMax && parseInt(d.start_year) <= dateMax && parseInt(d.end_year) >= dateMin;
          });
          // console.log(thresholdLinks)
          var newData = parseComplexity(thresholdLinks, complexity, sources);

          // console.log(newData);

          var graph = {}
            // Define array of links
          graph.links = newData[1];

          var bridges10 = newData[1].filter(function(d) {
            return d.distance === 2;
          })

          var bridges = newData[0].filter(function(d) {
            // console.log(d)
            return d.distance === 3;
          })
          // console.log(bridges);

          // Define array of nodes
          graph.nodes = newData[0];

          var container = svg.append('g')

          //Fixed node positions for source nodes
          var sourceId1 = sources[0],
              sourceId2 = sources[1];

          graph.nodes.forEach( function(d) {
            if (d.id == sourceId1) {
              d.fx = width/8;
              d.fy = height/2;
            }
            if (d.id == sourceId2) {
              d.fx = width * (7/8)
              d.fy = height/2
            }
          })

          //          //
          //  LINKS   //
          //          //

          var link = container.append("g")
            .attr("class", "links")
            .selectAll(".link");

          // Sort "newlinks" array so to have the "altered" links at the end and display them on "foreground"
          graph.links.sort(function(a, b) {
            if (a.altered) {
              return 1
            }
          });

          // Data join with only new links from parseComplexity()
          link = link.data(graph.links, function(d) {
            return d.source.id + ', ' + d.target.id;
          });

          var linkEnter = link.enter().append('path') // Create enter variable for general update pattern

          link.exit().remove(); // Remove exiting links

          link = linkEnter.merge(link) // Merge new links
            .attr('class', 'link')
            .classed('altered', function(d) { // Style if link has been "altered" by a person
              return d.altered ? true : false;
            })
            .on('click', function(d) { // Toggle link on click
              toggleClick(d, graph.links);
            });




          //          //
          //  NODES   //
          //          //


          var node = container.append("g")
            .attr("class", "nodes")
            .selectAll(".node");

          // Data join with only new nodes from parseComplexity()
          node = node.data(graph.nodes, function(d) {
              return d.id;
            })

          var nodeEnter = node.enter().append('circle'); // Create enter variable for general update pattern


          node.exit().remove(); // Remove exiting nodes

          node = nodeEnter.merge(node) // Merge new nodes
            .attr('class', function(d) { // Class by degree of distance
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
            })
            .attr('id', function(d) { // Assign ID number
              return "n" + d.id.toString();
            })
            .attr('r', function(d) { // Size nodes by degree of distance
              if (d.distance === 0 || d.distance === 3) {
                return 25;
              } else if (d.distance === 2) {
                return 12.5;
              } else {
                return 6.25;
              }
            })
            .on('click', function(d) {
              // Toggle ego networks on click of node
              toggleClick(d, graph.links, this);
            })
            // On hover, display label
            .on('mouseenter', function(d) {
              d3.selectAll('g.label').classed('temporary-unhidden', function(e) {
                // console.log(typeof e.id);
                return (e.id === d.id) ? true: false;
              })
              // sort elements so to bring the hovered one on top and make it readable.
              // svg.selectAll("g.label").each(function(e, i) {
              //   if (d == e) {
              //     var myElement = this;
              //     d3.select(myElement).remove();
              //     d3.select('.labels').node().appendChild(myElement);
              //   }
              // })
            })
            .on('mouseleave', function(d) {
              d3.selectAll('g.label').classed('temporary-unhidden', function(e) {
                if (e.id == d.id) { return false; }
              })
            });




          //          //
          //  LABELS  //
          //          //

          var label = container.append("g")
            .attr("class", "labels")
            .selectAll(".label");

          // Data join with only new nodes from parseComplexity()
          label = label.data(graph.nodes, function(d) {
            return d.id;
          });

          label.exit().remove(); // Remove exiting labels

          // Create group for the label but define the position later
          var labelEnter = label.enter().append('g')
            .attr("class", function(d) {
              return (d.distance === 0) ? 'label' : 'label hidden';
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

          var zoom = d3.zoom(); // Create a single zoom function
          // Call zoom for svg container.
          svg.call(zoom.on('zoom', zoomed)); //.on("dblclick.zoom", null); // See zoomed() below


          // //Functions for zoom and recenter buttons
          // scope.centerNetwork = function() {
          //   console.log("Recenter");
          //   var sourceNode = nodes.filter(function(d) { return (d.id == sourceId)})[0]; // Get source node element by its ID
          //   // Transition source node to center of rect
          //   svg.transition().duration(750).call(zoom.transform, d3.zoomIdentity.translate(width/2-sourceNode.x, height/2-sourceNode.y));
          // }
          //
          // scope.zoomIn = function() {
          //   console.log("Zoom In")
          //   svg.transition().duration(500).call(zoom.scaleBy, zoomfactor + .5); // Scale by adjusted zoomfactor
          // }
          // scope.zoomOut = function() {
          //   console.log("Zoom Out")
          //   svg.transition().duration(500).call(zoom.scaleBy, zoomfactor - .25); // Scale by adjusted zoomfactor, slightly lower since zoom out was more dramatic
          // }

          // Zooming function translates the size of the svg container on wheel scroll.
          function zoomed() {
            container.attr("transform", "translate(" + d3.event.transform.x + ", " + d3.event.transform.y + ") scale(" + d3.event.transform.k + ")");
          }

          simulation.restart();



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

              node // Take x and y values from data
                  .attr("cx", function(d) { return d.x; })
                  .attr("cy", function(d) { return d.y; });

              label // Position labels in center of nodes
                  .attr("transform", function(d) {
                    return "translate(" + (d.x) + "," + (d.y + 2.5) + ")"
                  })
            }
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

          // Change name of the viz
          scope.config.title = "W. Shakespeare and J. Milton - Force Layout"
        }

        scope.$on('shared network query', function(event, args) {
          console.log(event, args);
          updateSharedNetwork(args);
          // apiService.getFile('./data/sharednetwork.json').then(function(data) {
          //   console.log('sharedData', data);

          //   updateSharedNetwork(data);

          // });

        })


      }
    };
  });
