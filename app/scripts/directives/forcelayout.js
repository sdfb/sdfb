'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:forceLayout
 * @description
 * # forceLayout
 */
angular.module('redesign2017App')
  .directive('forceLayout', function() {
    return {
      template: '<svg width="100%" height="100%"></svg>',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        console.log('drawing network the first time');
        // console.log(scope.data);
        var svg = d3.select(element[0]).select('svg'),
          width = +svg.node().getBoundingClientRect().width,
          height = +svg.node().getBoundingClientRect().height,
          nodes,
          links,
          degreeSize,
          sourceId,
          confidenceMin = scope.config.confidenceMin,
          confidenceMax = scope.config.confidenceMax,
          dateMin = scope.config.dateMin,
          dateMax = scope.config.dateMax,
          complexity = scope.config.networkComplexity;

        var durationTransition = 500;


        // COMPLEXITY PARSER
        function parseComplexity(thresholdLinks, complexity) {
          // console.log('parseComplexity');

          var oneDegreeNodes = [];
          thresholdLinks.forEach(function(l) {
            if (l.source.id == sourceId || l.target.id == sourceId) {
              oneDegreeNodes.push(l.source);
              oneDegreeNodes.push(l.target);
            };
          });
          oneDegreeNodes = Array.from(new Set(oneDegreeNodes));
          var twoDegreeNodes = [];
          thresholdLinks.forEach(function(l) {
            if (oneDegreeNodes.indexOf(l.source) != -1 && oneDegreeNodes.indexOf(l.target) == -1) {
              twoDegreeNodes.push(l.target);
            } else if (oneDegreeNodes.indexOf(l.target) != -1 && oneDegreeNodes.indexOf(l.source) == -1) {
              twoDegreeNodes.push(l.source);
            };
          });
          twoDegreeNodes = Array.from(new Set(twoDegreeNodes));
          var allNodes = oneDegreeNodes.concat(twoDegreeNodes);
          allNodes.forEach(function(d) {
            if (d.id == sourceId) {
              d.distance = 0;
            } else if (oneDegreeNodes.indexOf(d) != -1) {
              d.distance = 1;
            } else {
              d.distance = 2;
            }
          });
          if (complexity == '1') {
            var newLinks = thresholdLinks.filter(function(l) {
              if (l.source.id == sourceId || l.target.id == sourceId) {
                return l;
              }
            })
            return [oneDegreeNodes, newLinks];
          }
          if (complexity == '1.5') {
            var newLinks = thresholdLinks.filter(function(l) {
              if (oneDegreeNodes.indexOf(l.source) != -1 && oneDegreeNodes.indexOf(l.target) != -1) {
                return l;
              }
            });
            return [oneDegreeNodes, newLinks];
          }
          if (complexity == '1.75') {
            var newNodes = [];
            twoDegreeNodes.forEach(function(d) {
              var count = 0;
              thresholdLinks.forEach(function(l) {
                if (l.source == d && oneDegreeNodes.indexOf(l.target) != -1) {
                  count += 1;
                } else if (l.target == d && oneDegreeNodes.indexOf(l.source) != -1) {
                  count += 1;
                }
              });
              if (count >= 2) {
                newNodes.push(d);
              }
            });
            // newNodes = Array.from(new Set(newNodes));
            newNodes = oneDegreeNodes.concat(newNodes);
            newLinks = thresholdLinks.filter(function(l) {
              if (newNodes.indexOf(l.source) != -1 && newNodes.indexOf(l.target) != -1) {
                return l;
              }
            });
            return [newNodes, newLinks];
          }
          if (complexity == '2') {
            newLinks = thresholdLinks.filter(function(l) {
              if (oneDegreeNodes.indexOf(l.source) != -1 || oneDegreeNodes.indexOf(l.source) != -1) {
                return l;
              }
            });
            return [allNodes, newLinks];
          }
          if (complexity == '2.5') {
            var newLinks = thresholdLinks.filter(function(l) {
              if (allNodes.indexOf(l.source) != -1 && allNodes.indexOf(l.target) != -1) {
                return l;
              }
            });
            return [allNodes, newLinks];
          }
        }


        // Draw curved edges
        function linkArc(d) {
          var dx = d.target.x - d.source.x,
            dy = d.target.y - d.source.y,
            dr = Math.sqrt(dx * dx + dy * dy);
          return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
        }


        // A function to handle click toggling based on neighboring nodes.
        function toggleClick(d, newLinks, selectedElement) {

          // Reset group bar
          d3.selectAll('.group').classed('active', false);
          d3.selectAll('.group').classed('unactive', false);

          if (d.type == "person") {

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

            var numberOfConnections = Object.keys(connectedNodes).length;

            if (numberOfConnections <= 20) {
              d3.selectAll('g.label')
                .classed('hidden', function(m) {
                  return !(m.id in connectedNodes);
                });
            } else {
              var neighborsByConfidence = [];
              for (var m in connectedNodes) {
                newLinks.forEach(function(l) {
                  if ((l.source.id == m && l.target.id == d.id) || (l.source.id == d.id && l.target.id == m)) {
                    neighborsByConfidence.push([m, l.weight]);
                  }
                });
              }

              neighborsByConfidence.sort(function(first, second) {
                return second[1] - first[1];
              });

              var top20 = neighborsByConfidence.slice(0, 20);

              var top20object = {};
              top20.forEach(function(t) { top20object[t[0]] = t[1]; });
              // console.log(top20object);

              d3.selectAll('g.label')
                .classed('hidden', function(m) {
                  if (m.id != d.id) {
                    // var linkFound = newLinks.filter(function(l){ return ((l.source.id == m.id && l.target.id == d.id) || (l.source.id == d.id && l.target.id == m.id)); });
                    return (m.id in top20object) ? false : true;
                  } else {
                    return false;
                  }
                });
            }

            // This triggers events in groupsbar.js and contextualinfopanel.js when a selection happens
            scope.currentSelection = d;
            scope.$broadcast('selectionUpdated', scope.currentSelection);

          } else if (d.type == "relationship") {
            // Remove selction from nodes and labels
            d3.selectAll('.node, g.label').classed('selected', false);

            d3.selectAll('.link')
              .classed('faded', function(l) {
                return (l == d) ? false : true;
              })

            d3.selectAll('.node')
              .classed('faded', function(n) {
                return (n == d.source || n == d.target) ? false : true;
              })

            d3.selectAll('g.label')
              .classed('hidden', function(m) {
                return (m == d.source || m == d.target) ? false : true;
              })

            console.log('selection to be implemented');
            // This triggers events in groupsbar.js and contextualinfopanel.js when a selection happens
            scope.currentSelection = d;
            scope.$broadcast('selectionUpdated', scope.currentSelection);
          }

        }

        svg.append('rect')
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
                return (d.distance < 2) ? false : true;
              });

            // reset group bar
            d3.selectAll('.group').classed('active', false);
            d3.selectAll('.group').classed('unactive', false);

            // update selction and trigger event for other directives
            scope.currentSelection = {};
            scope.$apply(); // no need to trigger events, just apply
          });


        var zoom = d3.zoom();
        // Call zoom for svg container.
        svg.call(zoom.on('zoom', zoomed)); //.on("dblclick.zoom", null);
        

        //Functions for zoom and recenter buttons
        scope.centerNetwork = function() {
          console.log("Recenter");
          var sourceNode = nodes.filter(function(d) { return (d.id == sourceId)})[0];
          svg.transition().duration(750).call(zoom.transform, d3.zoomIdentity.translate(width/2-sourceNode.x, height/2-sourceNode.y));
          // svg.transition().duration(750).call(zoom.transform, d3.zoomIdentity);
        }
        var zoomfactor = 1;
        scope.zoomIn = function() {
          console.log("Zoom In")
          svg.transition().duration(500).call(zoom.scaleBy, zoomfactor + .5);
        }
        scope.zoomOut = function() {
          console.log("Zoom Out")
          svg.transition().duration(500).call(zoom.scaleBy, zoomfactor - .25);
        }

        // Zooming function translates the size of the svg container.
        function zoomed() {
          container.attr("transform", "translate(" + d3.event.transform.x + ", " + d3.event.transform.y + ") scale(" + d3.event.transform.k + ")");
          // if (d3.event.transform.k < 2) {
          //   console.log(1)
          // } else if (d3.event.transform.k < 3) {
          //   console.log(3 - 1);
          //   // console.log(d3.selectAll('g.label'));
          // } else if (d3.event.transform.k < 4) {
          //   console.log(4 - 1)
          // } else {
          //   console.log(4)
          // }
        }



        var container = svg.append('g');

        // Toggle for ego networks on click (below).
        var toggle = 0;

        var link = container.append("g")
          .attr("class", "links")
          .selectAll(".link");

        var node = container.append("g")
          .attr("class", "nodes")
          .selectAll(".node");

        var label = container.append("g")
          .attr("class", "labels")
          .selectAll(".label");


        var loading = svg.append("text")
          .attr("dy", "0.35em")
          .attr("text-anchor", "middle")
          .attr('x', width / 2)
          .attr('y', height / 2)
          .attr("font-family", "sans-serif")
          .attr("font-size", 10)
          .text("Simulating. One moment please…");

        var t0 = performance.now();

        var json = scope.data;

        // graph = json.data.attributes;
        nodes = json.included;
        links = [];
        json.data.attributes.connections.forEach(function(c) { links.push(c.attributes) });
        sourceId = json.data.attributes.primary_people;

        // d3.select('.legend .size.min').text('j')

        var simulation = d3.forceSimulation(nodes)
          // .velocityDecay(.5)
          .force("link", d3.forceLink(links).id(function(d) {
            return d.id;
          }))
          .force("charge", d3.forceManyBody().strength(-75)) //.distanceMax([500]))
          .force("center", d3.forceCenter(width / 2, height / 2))
          .force("collide", d3.forceCollide().radius(function(d) {
            if (d.id == sourceId) {
              return 26;
            } else {
              return 13;
            }
          }))
          // .force("x", d3.forceX())
          // .force("y", d3.forceY())
          .stop();

        for (var i = 0, n = Math.ceil(Math.log(simulation.alphaMin()) / Math.log(1 - simulation.alphaDecay())); i < n; ++i) {
          simulation.tick();
        }



        loading.remove();



        var t1 = performance.now();

        console.log("Graph took " + (t1 - t0) + " milliseconds to load.")

        function positionCircle(nodelist, r) {
          var angle = 360/nodelist.length;
          nodelist.forEach( function(n, i) {
            n.fx = (Math.cos(angle*(i+1))*r)+(width/2);
            n.fy = (Math.sin(angle*(i+1))*r)+(height/2);
          });
        }

        function update(confidenceMin, confidenceMax, dateMin, dateMax, complexity, layout) {
          console.log('force layout update function');
          // Find the links and nodes that are at or above the confidenceMin.
          var thresholdLinks = links.filter(function(d) {
            if (d.weight >= confidenceMin && d.weight <= confidenceMax && parseInt(d.start_year) <= dateMax && parseInt(d.end_year) >= dateMin) {
              return d;
            };
          });

          var newData = parseComplexity(thresholdLinks, complexity);
          // console.log(newData);
          var newNodes = newData[0];
          var newLinks = newData[1];

          // Example of how to execute different code depending on the yellow-layout-switch (it is in the search panel)
          if (layout == 'individual-force') {
            console.log('Layout: individual-force');
            newNodes.forEach(function(d){
              d.fx = null;
              d.fy = null;
            });
          } else if (layout == 'individual-concentric') {
            console.log('Layout: individual-concentric');
            newNodes.forEach( function(d) {
              if (d.distance == 0) {
                d.fx = width/2;
                d.fy = height/2;
              }
            })

            var oneDegreeNodes = newNodes.filter(function(d) {if (d.distance == 1) {return d;} });
            positionCircle(oneDegreeNodes, 200);

            var twoDegreeNodes = newNodes.filter(function(d) {if (d.distance == 2) {return d;} });
            positionCircle(twoDegreeNodes, 1000);
          } else {
            console.log('ERROR: No compatible layout selected:', layout);
          }

          var simulation = d3.forceSimulation(nodes)
            // .velocityDecay(.5)
            .force("link", d3.forceLink(links).id(function(d) {
              return d.id;
            }))
            .force("charge", d3.forceManyBody().strength(-75)) //.distanceMax([500]))
            .force("center", d3.forceCenter(width / 2, height / 2))
            .force("collide", d3.forceCollide().radius(function(d) {
              if (d.id == sourceId) {
                return 26;
              } else {
                return 13;
              }
            }))
            // .force("x", d3.forceX())
            // .force("y", d3.forceY())
            .stop();

          for (var i = 0, n = Math.ceil(Math.log(simulation.alphaMin()) / Math.log(1 - simulation.alphaDecay())); i < n; ++i) {
            simulation.tick();
          }
          // d3.select('.source-node').remove(); //Get rid of old source node highlight.



          //          //
          //  LINKS   //
          //          //

          // Add property "type" : "relationship" to every link
          newLinks.forEach(function(link) {
            if (!link.type) {
              link.type = 'relationship';
            }
          })

          // Sort "newlinks" array so to have the "altered" links at the end and display them on "foreground"
          newLinks.sort(function(a, b) {
            if (a.altered) {
              return 1
            }
          });
          // Data join with only those new links and corresponding nodes.
          link = link.data(newLinks, function(d) {
            return d.source.id + ', ' + d.target.id;
          });

          var linkEnter = link.enter().append('path')
            // .attr('class', 'link faded');

          link.exit().remove();

          link = linkEnter.merge(link)
            .attr('class', 'link')
            .classed('altered', function(d) {
              return d.altered ? true : false;
            })
            .attr("d", linkArc)
            .on('click', function(d) {
              toggleClick(d, newLinks);
            });










          //          //
          //  NODES   //
          //          //

          // When adding and removing nodes, reassert attributes and behaviors.
          node = node.data(newNodes, function(d) {
              return d.id;
            })

          var nodeEnter = node.enter().append('circle');

          node.exit().remove();

          node = nodeEnter.merge(node)
            .attr('class', function(d) {
              return 'node degree' + d.distance
            })
            .attr('id', function(d) {
              return "n" + d.id.toString();
            })
            .attr("cx", function(d) {
              return d.x;
            })
            .attr("cy", function(d) {
              return d.y;
            })
            .attr("is_source", function(d) {
              if (d.id == sourceId) {
                return 'true';
              }
            })
            .attr('r', function(d) {
              if (d.distance == 0) {
                return 25;
              } else if (d.distance == 1) {
                return 12.5;
              } else {
                return 6.25;
              }
            })
            .on('click', function(d) {
              // Handle the rest of selection signifiers
              toggleClick(d, newLinks, this);
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
              svg.selectAll("g.label").each(function(e, i) {
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















          //          //
          //  LABELS  //
          //          //

          label = label.data(newNodes, function(d) {
            return d.id;
          });

          label.exit().remove();

          // Create group for the label but define the position later
          var labelEnter = label.enter().append('g')
            .attr("class", function(d) {
              return (d.distance < 2) ? 'label' : 'label hidden';
            });

          label.selectAll('*').remove();

          label = labelEnter.merge(label);

          label.append('rect') // a placeholder to be reworked later

          label.append('text')
            .text(function(d) {
              // console.warn(d.attributes.name);
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

          // Center the label in the middle of the node circle
          d3.selectAll('g.label')
            .attr("transform", function(d) {
              return "translate(" + (d.x) + "," + (d.y + 2.5) + ")"
            })

          scope.centerNetwork();
          
          // Change name of the viz
          scope.config.title = "Hooke network of Francis Bacon"
        }

        // Trigger update automatically when the directive code is executed entirely (e.g. at loading)
        update(confidenceMin, confidenceMax, dateMin, dateMax, complexity, 'individual-force');

        // update triggered from the controller
        scope.$on('Update the force layout', function(event, args) {
          console.log('ON: Update the force layout')
          confidenceMin = scope.config.confidenceMin;
          confidenceMax = scope.config.confidenceMax;
          dateMin = scope.config.dateMin;
          dateMax = scope.config.dateMax;
          complexity = scope.config.networkComplexity;
          update(confidenceMin, confidenceMax, dateMin, dateMax, complexity, args.layout);
        });

      }
    };
  });
