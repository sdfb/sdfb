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

        // HIDDEN SEARCH BAR SINCE NOT WORKING.
        // Search for nodes by making all unmatched nodes temporarily transparent.
        // function searchNodes() {
        //  var term = document.getElementById('searchTerm').value;
        //  var selected = container.selectAll('.node').filter(function(d, i) {
        //    return d.name.toLowerCase().search(term.toLowerCase()) == -1;
        //  });
        //  selected.style('opacity', '0');
        //  var link = container.selectAll('.link');
        //  link.style('stroke-opacity', '0');
        //  d3.selectAll('.node').transition()
        //    .duration(5000)
        //    .style('opacity', '1');
        //  d3.selectAll('.link').transition().duration(5000).style('stroke-opacity', '0.6');
        // }
        // Create form for search (see function below).
        // var search = d3.select("div#tools").append('form').attr('onsubmit', 'return false;');
        // var box = search.append('input')
        //  .attr('type', 'text')
        //  .attr('id', 'searchTerm')
        //  .attr('placeholder', 'Type to search...');
        // var button = search.append('input')
        //  .attr('type', 'button')
        //  .attr('value', 'Search')
        //  .on('click', function() {
        //    searchNodes();
        //  });

        // COMPLEXITY SLIDER AND PARSER
        function parseComplexity(thresholdLinks, complexity) {
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
            // var newLinks = thresholdLinks.filter(function(l) {if (oneDegreeNodes.indexOf(l.source) != -1 || oneDegreeNodes.indexOf(l.target) != -1) {return l;}});
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
        function toggleClick(d, newLinks) {

          // Reset group bar
          d3.selectAll('.group').classed('active', false);
          d3.selectAll('.group').classed('unactive', false);

          if (d.type == "person") {

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

            d3.selectAll('g.label')
              .classed('hidden', function(m) {
                return !(m.id in connectedNodes);
              })

            // scope.currentSelection.person1 = {id:d.id, name:d.attributes.name, historical_significance:d.attributes.historical_significance, birth_year:d.attributes.birth_year, death_year:d.attributes.death_year};
            scope.currentSelection = d;

            // This triggers events in groupsbar.js and contextualinfopanel.js when a selection happens
            scope.$broadcast('selectionUpdated', scope.currentSelection);

          } else if( d.type == "relationship") {
            console.log(d.type, d);

            d3.selectAll('.link')
              .classed('faded', function(l){
                return (l == d)?false:true;
              })

            d3.selectAll('.node')
              .classed('faded', function(n){
                return (n == d.source || n == d.target)?false:true;
              })

            d3.selectAll('g.label')
              .classed('hidden', function(m) {
                return (m == d.source || m == d.target)?false:true;
              })

            // scope.currentSelection.person1 = {id:d.id, name:d.attributes.name, historical_significance:d.attributes.historical_significance, birth_year:d.attributes.birth_year, death_year:d.attributes.death_year};
            // scope.currentSelection = d;

            // This triggers events in groupsbar.js and contextualinfopanel.js when a selection happens
            // scope.$broadcast('selectionUpdated', scope.currentSelection);
            console.log('selection to be implemented');
          }

        }

        svg.append('rect')
          .attr('width', '100%')
          .attr('height', '100%')
          .attr('fill', 'transparent')
          .on('click', function() {

            // Restore nodes and links to normal opacity. (see toggleClick() below)
            d3.selectAll('.link')
              .classed('faded', false)
              // .classed('focused', false);

            d3.selectAll('.node')
              .classed('faded', false)
              // .classed('focused', false);

            // Must select g.labels since it selects elements in other part of the interface
            d3.selectAll('g.label')
              .classed('hidden', function(d) {
                return (d.distance < 2) ? false : true; })

            // reset group bar
            d3.selectAll('.group').classed('active', false);
            d3.selectAll('.group').classed('unactive', false);

            // update selction and trigger event for other directives
            scope.currentSelection = {};
            scope.$apply(); // no need to trigger events, just apply
          }); //on()

        // Zooming function translates the size of the svg container.
        function zoomed() {
          container.attr("transform", "translate(" + d3.event.transform.x + ", " + d3.event.transform.y + ") scale(" + d3.event.transform.k + ")");
        }
        // Call zoom for svg container.
        // svg.call(d3.zoom().transform, d3.zoomTransform().translate(0,0).scale(1));
        // svg.call(d3.zoom().extent([[0,0], [svg.attr("width"),svg.attr("height")]]))
        svg.call(d3.zoom().on('zoom', zoomed)); //.on("dblclick.zoom", null);

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

        degreeSize = d3.scaleLog()
          .domain([d3.min(nodes, function(d) {
            return d.attributes.degree;
          }), d3.max(nodes, function(d) {
            return d.attributes.degree;
          })])
          .range([10, 45]);

        // d3.select('.legend .size.min').text('j')

        var simulation = d3.forceSimulation(nodes)
          // .velocityDecay(.5)
          .force("link", d3.forceLink(links).id(function(d) {
            return d.id;
          }))
          .force("charge", d3.forceManyBody().strength(-125)) //.distanceMax([500]))
          .force("center", d3.forceCenter(width / 2, height / 2))
          .force("collide", d3.forceCollide().radius(function(d) {
            if (d.id == sourceId) { return 26; }
            else { return 13; }
          // return degreeSize(d.attributes.degree) + 1;
          }))
          .force("x", d3.forceX())
          .force("y", d3.forceY())
          .stop();

        loading.remove();

        for (var i = 0, n = Math.ceil(Math.log(simulation.alphaMin()) / Math.log(1 - simulation.alphaDecay())); i < n; ++i) {
          simulation.tick();
        }

        var t1 = performance.now();

        console.log("Graph took " + (t1 - t0) + " milliseconds to load.")

        function update(confidenceMin, confidenceMax, dateMin, dateMax, complexity) {
          console.log('updating the force layout');
          d3.select('.source-node').remove(); //Get rid of old source node highlight.

          // Find the links and nodes that are at or above the confidenceMin.
          var thresholdLinks = links.filter(function(d) {
            if (d.weight >= confidenceMin && d.weight <= confidenceMax && parseInt(d.start_year) <= dateMax && parseInt(d.end_year) >= dateMin) {
              return d;
            };
          });

          var newData = parseComplexity(thresholdLinks, complexity);
          var newNodes = newData[0];
          var newLinks = newData[1];

          // Add property "type" : "relationship" to every link
          newLinks.forEach(function(link) {
            // console.log(link);
            if (!link.type) {
              link.type = 'relationship';
            } else {
              console.log(link.type);
            }
          })

          // Sort "newlinks" array so to have the "altered" links at the end and display them on "foreground"
          newLinks.sort(function(a, b) {
            if (a.altered) {
              return 1 }
          });
          // Data join with only those new links and corresponding nodes.
          link = link.data(newLinks, function(d) {
            return d.source.id + ', ' + d.target.id;
          });
          link.exit().remove();
          var linkEnter = link.enter().append('path')
            .attr('class', 'link');

          link = linkEnter.merge(link)
            .attr('class', 'link')
            .classed('altered', function(d) {
              return d.altered ? true : false; })
            .attr("d", linkArc)
            .on('click', function(d) {
              toggleClick(d, newLinks);
            });

          // When adding and removing nodes, reassert attributes and behaviors.
          node = node.data(newNodes, function(d) {
              return d.id;
            })
            .attr('class', function(d) {
              return 'node degree' + d.distance
            });
          // .attr("cx", function(d) { return d.x; })
          // .attr("cy", function(d) { return d.y; });
          node.exit().remove();
          var nodeEnter = node.enter().append('circle');

          // node.attr('r', 20);
          // node.attr('r', function(d) { return degreeSize(d.attributes.degree); });

          node = nodeEnter.merge(node)
            // .attr('r', 20)
            // .attr('r', function(d) { return degreeSize(d.attributes.degree); })
            // .attr('r', radius - 1)
            // .attr('r', function(d) { return degreeSize(d.attributes.degree); })
            // .attr("fill", function(d) { return color(d.distance); })
            .attr('class', function(d) {
              return 'node degree' + d.distance
            })
            .attr('id', function(d) {
              return "n" + d.id.toString();
            })
            .attr("cx", function(d) {
              return d.x; // = Math.max(radius, Math.min(width - radius, d.x));
            })
            .attr("cy", function(d) {
              return d.y; // = Math.max(radius, Math.min(height - radius, d.y));
            })
            // .attr("pulse", false)
            .attr("is_source", function(d) {
              if (d.id == sourceId) {
                return 'true';
              }
            })
            // On click, toggle ego networks for the selected node. (See function above.)
            .on('click', function(d) {
              toggleClick(d, newLinks);
            });

          node.append("title")
            .text(function(d) {
              return d.attributes.name;
            });

          // LABELS
          label = label.data(newNodes, function(d) {
            return d.id;
          });

          label.exit().remove();

          // Create group for the label but define the position later
          var labelEnter = label.enter().append('g')
            .attr("class", "label")
            .classed('hidden', function(d) {
              return (d.distance < 2) ? false : true; })
            .on('click', function(d) {
              toggleClick(d, newLinks);
            })
            .on("mouseenter", function(d) {
              // reorder elements so to bring the hovered one on top and make it readable.
              svg.selectAll("g.label").each(function(e, i) {
                if (d == e) {
                  var myElement = this;
                  d3.select(myElement).remove();
                  d3.select('.labels').node().appendChild(myElement);
                }
              })
            })

          label = labelEnter.merge(label)

          label.append('rect') // a placeholder to be reworked later

          label.append('text')
            .text(function(d) {
              return d.attributes.name; })

          // Get the Bounding Box of the text created
          d3.selectAll('.label text').each(function(d, i) {
            // Originally used getBBox, but not compatible with firefox
            // newNodes[i].labelBBox = this.getBBox();
            // newNodes[i].labelBBox = this.getBoundingClientRect();
            d.labelBBox = this.getBoundingClientRect(); // Throwing error with newNodes[i]
          });

          // adjust the padding values depending on font and font size
          var paddingLeftRight = 4;
          var paddingTopBottom = 0;

          // set dimentions and positions of rectangles depending on the BBox exctracted before
          d3.selectAll(".label rect")
            .attr("x", function(d) {
              return 0 - d.labelBBox.width / 2 - paddingLeftRight / 2; })
            .attr("y", function(d) {
              return 0 + 3 - d.labelBBox.height + paddingTopBottom / 2; })
            .attr("width", function(d) {
              return d.labelBBox.width + paddingLeftRight; })
            .attr("height", function(d) {
              return d.labelBBox.height + paddingTopBottom; });

          // center the label in the middle of the node circle
          d3.selectAll('.label')
            .attr("transform", function(d) {
              return "translate(" + (d.x) + "," + (d.y + 2.5) + ")"
            })



          //Update legend too
          // scope.sizeMin = degreeSize.domain()[0];
          // scope.sizeMax = degreeSize.domain()[1]

          //Change name of the viz
          scope.config.title = "Hooke network of Francis Bacon"
        }

        update(confidenceMin, confidenceMax, dateMin, dateMax, complexity);

        // update triggered from the controller
        scope.$on('force layout update', function(event, args) {
          console.log(event, args);
          confidenceMin = scope.config.confidenceMin;
          confidenceMax = scope.config.confidenceMax;
          dateMin = scope.config.dateMin;
          dateMax = scope.config.dateMax;
          complexity = scope.config.networkComplexity;
          update(confidenceMin, confidenceMax, dateMin, dateMax, complexity);
        });

        var data4groups = scope.data.included
        var listGroups = [];
        data4groups.forEach(function(d) {
          if (d.attributes.groups) {
            d.attributes.groups.forEach(function(e) {
              listGroups.push(e);
            })
          }
        });

        // GET DATA FOR GROUPS
        // use lodash to create a dictionary with groupId as key and group occurrencies as value (eg '81': 17)
        listGroups = _.countBy(listGroups);

        //Transform that dictionary into an array of objects (eg {'groupId': '81', 'value': 17})
        var arr = [];
        for (var group in listGroups) {
          if (listGroups.hasOwnProperty(group)) {
            var obj = {
              'groupId': group,
              'value': listGroups[group]
            }
            arr.push(obj);
          }
        }

        //Sort the array in descending order
        arr.sort(function(a, b) {
          return d3.descending(a.value, b.value);
        })

        var cutAt = 20;
        var groupsBar = _.slice(arr, 0, cutAt);
        var otherGroups = _.slice(arr, cutAt);
        var othersValue = 0;
        otherGroups.forEach(function(d) {
          othersValue += d.value;
        });
        groupsBar.push({ 'groupId': 'others', 'value': othersValue });
        scope.groups.groupsBar = groupsBar;
        scope.groups.otherGroups = otherGroups;
        console.log('Data for groups bar ($scope.groups):', scope.groups);

      }
    };
  });
