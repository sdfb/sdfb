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
          // console.log('parseComplexity');

          // console.log(thresholdLinks)

          var oneDegreeNodes = [];
          thresholdLinks.forEach(function(l) {
            // See if any source or target matches with any source node
            sources.forEach(function(s) {
              if (l.source.id == s || l.target.id == s) {
                oneDegreeNodes.push(l.source);
                oneDegreeNodes.push(l.target);
              };
            })
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
            sources.forEach(function(s, i) {
              if (d.id == s) {
                d['distance' + i] = 0;
              } else if (oneDegreeNodes.indexOf(d) != -1) {

                d['distance' + i] = 1;

              } else {
                d['distance' + i] = 2;
              }
            })
          });

          if (complexity == '1') {
            var newLinks = thresholdLinks.filter(function(l) {
              sources.forEach(function(s) {
                if (l.source.id == s || l.target.id == s) {
                  return l;
                }
              })

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

        var simulation = d3.forceSimulation()
          .force("link", d3.forceLink().id(function(d) {
            return d.id;
          }))
          .force("charge", d3.forceManyBody().strength(-100))
          .force("center", d3.forceCenter(width / 2, height / 2))
          .force("collide", d3.forceCollide().radius(20));

        function dragstarted(d) {
          if (!d3.event.active) simulation.alphaTarget(0.3).restart();
          d.fx = d.x;
          d.fy = d.y;
        }

        function dragged(d) {
          d.fx = d3.event.x;
          d.fy = d3.event.y;
        }

        function dragended(d) {
          if (!d3.event.active) simulation.alphaTarget(0);
          d.fx = null;
          d.fy = null;
        }

        function updateSharedNetwork(json) {

          var links = [];
          json.data.attributes.connections.forEach(function(c) { links.push(c.attributes) });

          links.forEach(function(l) {
            var thisSource = json.included.filter(function(n) {
              return l.source == n.id;
            })
            l.source = thisSource[0];
            var thisTarget = json.included.filter(function(n) {
              return l.target == n.id;
            })
            l.target = thisTarget[0];
          })

          var confidenceMin = scope.config.confidenceMin,
            confidenceMax = scope.config.confidenceMax,
            dateMin = scope.config.dateMin,
            dateMax = scope.config.dateMax,
            complexity = scope.config.networkComplexity,
            sources = json.data.attributes.primary_people



          var thresholdLinks = links.filter(function(d) {
            return d.weight >= confidenceMin && d.weight <= confidenceMax && parseInt(d.start_year) <= dateMax && parseInt(d.end_year) >= dateMin;
          });
          // console.log(thresholdLinks)
          var newData = parseComplexity(thresholdLinks, complexity, sources);

          console.log(newData);

          var graph = {}
            // Define array of links
          graph.links = newData[1];

          var bridges10 = newData[1].filter(function(d) {
            return d.distance0 == 0 && d.distance1 == 1;
          })

          var bridges = newData[0].filter(function(d) {
            console.log(d)
            return d.distance0 == 1 && d.distance1 == 1;
          })
          console.log(bridges);

          // Define array of nodes
          graph.nodes = newData[0];

          simulation
            .nodes(graph.nodes)
            .on("tick", ticked);

          simulation.force("link")
            .links(graph.links);

          var link = svg.append("g")
            .attr("class", "links")
            .selectAll("line")
            .data(graph.links)
            .enter().append("line");

          var node = svg.append("g")
            .attr("class", "nodes")
            .selectAll("circle")
            .data(graph.nodes)
            .enter().append("circle")
            .attr("r", 2.5)
            .call(d3.drag()
              .on("start", dragstarted)
              .on("drag", dragged)
              .on("end", dragended));

          node.append("title")
            .text(function(d) {
              return d.id;
            });



          function ticked() {
            link
              .attr("x1", function(d) {
                return d.source.x;
              })
              .attr("y1", function(d) {
                return d.source.y;
              })
              .attr("x2", function(d) {
                return d.target.x;
              })
              .attr("y2", function(d) {
                return d.target.y;
              });

            node
              .attr("cx", function(d) {
                return d.x;
              })
              .attr("cy", function(d) {
                return d.y;
              });
          }

          // Change name of the viz
          scope.config.title = "W. Shakespeare and J. Milton - Force Layout"
        }

        scope.$on('shared network query', function(event, args) {
          // console.log(event, args);
          apiService.getFile('./data/sharednetwork.json').then(function(data) {
            console.log('sharedData', data);

            updateSharedNetwork(data);

          });

        })


      }
    };
  });
