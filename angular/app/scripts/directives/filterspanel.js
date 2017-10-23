'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:filtersPanel
 * @description
 * # filtersPanel
 */
angular.module('redesign2017App')
  .directive('filtersPanel', function() {
        return {
          templateUrl: './views/filters-panel.html',
          restrict: 'E',
          link: function postLink(scope, element, attrs) {
        var confidenceMin,
            confidenceMax,
            dateMin,
            dateMax,
            complexity,
            sources,
            links,
            args,
            startYear,
            endYear;

        scope.reloadFilters = function() {
          removeAll();
          sources = scope.data.data.attributes.primary_people;
          if (sources.length === 1) {
            var sourceId = sources[0], // ID of node the user searched for.
            sourceNode = getNodeInfo(sourceId); // Get object of attributes for sourceNode
            startYear = sourceNode.birth_year;
            endYear = sourceNode.death_year;
            createDensityButtons();
          }
          else if (sources.length === 2) {
            var sourceId1 = sources[0],
                sourceId2 = sources[1],
                sourceNode1 = getNodeInfo(sourceId1),
                sourceNode2 = getNodeInfo(sourceId2),
                birthYear1 = sourceNode1.birth_year,
                birthYear2 = sourceNode2.birth_year,
                deathYear1 = sourceNode1.death_year,
                deathYear2 = sourceNode2.death_year;

            startYear = Math.min(birthYear1, birthYear2);
            endYear = Math.max(deathYear1, deathYear2);
            createConnectionButtons();
          }

          confidenceMin = scope.config.confidenceMin,
          confidenceMax = scope.config.confidenceMax,
          dateMin = scope.config.dateMin,
          dateMax = scope.config.dateMax,
          complexity = scope.config.networkComplexity,
          links = [],
          args = scope.data;

          args.layout = scope.config.viewMode;
          // Populate links array from JSON
          scope.data.data.attributes.connections.forEach(function(c) {
            // Retain ID and type from level above in JSON
            c.attributes.id = c.id;
            c.attributes.type = c.type;
            links.push(c.attributes);
          });


          createConfidenceGraph();
          createDateGraph();
        }

        function getNodeInfo(id) {
          var sourceNode = scope.data.included.filter(function(d) { // Data corresponding to sourceID
            if (d.id.toString() === id) {
              return d;
            };
          })[0];
          sourceNode = sourceNode.attributes;
          return sourceNode;
        }

        function removeAll() {
          d3.select('.density-container form').remove();
          d3.select('.connection-container form').remove();
          d3.select('.confidence-container svg').remove();
          d3.select('.date-container svg').remove();
        }

        function showTooltip(d) {
          $('.interaction-info').text(function() {
            if (d == 1) {
              return 'Source person and 1-degree relationships';
            } else if (d == 1.5) {
              return 'Relationships among all 1-degree people';
            } else if (d == 1.75) {
              return 'All 1-degree people and 2-degree people with more than one 1-degree relationship';
            } else if (d == 2) {
              return 'All people; relationships between 1-degree and 2-degree people only';
            } else if (d == 2.5){
              return 'All 1- and 2-degree people and relationships';
            } else if (d == 'direct_connections') {
              return 'People on a direct path between the two searched people'
            } else if (d === 'all_connections') {
              return 'All people within one degree of either searched person'
            }
          });
        }

        function resetTooltip(d) {
          $('.interaction-info').text('Hover on a value to learn more');
        }

        function createDensityButtons() {
          // Radio buttons for network complexity.
          var complexity = '2';
          
          var complexityForm = d3.select('.density-container').append('form'); // Create form

          var complexityBox = complexityForm.selectAll('input') // Data join with 5-number scale
            .data(['1', '1.5', '1.75', '2', '2.5'])
            .enter().append('div');

          var complexityButtons = complexityBox.append('input')
            .attr('type', 'radio')
            .attr('name', 'complexity')
            .attr('id', function(d) {
              return 'radio-' + d;
            })
            .attr('checked', function(d) {
              if (d == complexity) {
                return 'checked';
              }
            })
            .attr('value', function(d) {
              return d;
            });
          complexityBox.append('label')
            .attr('for', function(d) {
              return 'radio-' + d;
            })
            .append('span')
            .on("mouseover", showTooltip)
            .on("mouseout", resetTooltip);

          complexityButtons.on('change', function() {

            // On change update value of networkComplexity config variable
            complexity = this.value;
            console.log(complexity);
            scope.$evalAsync(function() {
              scope.config.networkComplexity = complexity;
              // Trigger force layout update
              scope.updateNetwork(args);
            });
          });
        }

        function createConnectionButtons() {
          // Radio buttons for network complexity.
          var complexityForm = d3.select('.connection-container').append('form'); // Create form

          var complexityBox = complexityForm.selectAll('input') // Data join with 5-number scale
            .data(['direct_connections', 'all_connections'])
            .enter().append('div');

          var complexityButtons = complexityBox.append('input')
            .attr('type', 'radio')
            .attr('name', 'complexity')
            .attr('id', function(d) {
              return 'radio-' + d;
            })
            .attr('checked', function(d) {
              if (d == complexity) {
                return 'checked';
              }
            })
            .attr('value', function(d) {
              return d;
            });
          complexityBox.append('label')
            .attr('for', function(d) {
              return 'radio-' + d;
            })
            .append('span')
            .on("mouseover", showTooltip)
            .on("mouseout", resetTooltip);

          complexityButtons.on('change', function() {

            // On change update value of networkComplexity config variable
            complexity = this.value;
            console.log(complexity);
            scope.$evalAsync(function() {
              scope.config.networkComplexity = complexity;
              // Trigger force layout update
              scope.updateNetwork(args);
            });
          });
        }

        function countConfidenceFrequency() {
          // Create counts off all confidence values
          var confidence = d3.range(0, 101);
          var frequencies = {}; // create object of frequencies
          confidence.forEach(function(c) {
            frequencies[c.toString()] = 0; // first with values of 0
          });
          links.forEach(function(l) {
            frequencies[l.weight] += 1; // Then count up by weight
          });
          var data = []; // Return weights and frequencies as array
          for (var x in frequencies) {
            data.push({
              'weight': x,
              'count': frequencies[x]
            });
          }
          return data;
        }

        function countDateFrequency() {
          // Same as above with dates
          var years = d3.range(parseInt(startYear), parseInt(endYear) + 1); // Initial range is birth and death of source node
          var frequencies = {};
          years.forEach(function(y) {
            frequencies[y.toString()] = 0;
          });
          years.forEach(function(y) {
            links.forEach(function(l) {
              if (y >= l.start_year && y <= l.end_year) {
                frequencies[y.toString()] += 1;
              }
            });
          });
          var data = [];
          for (var x in frequencies) {
            data.push({
              'year': x,
              'count': frequencies[x]
            });
          }
          return data;
        }

        function createConfidenceGraph() {

          var confidenceData = countConfidenceFrequency(); // Get array of counts

          // Create svg for bar graph
          var confidenceGraph = d3.select('.confidence-container').append('svg').attr('width', 284).attr('height', 70),
            confidenceMargin = {
              top: 0,
              right: 0,
              bottom: 10,
              left: 0
            },
            confidenceWidth = +confidenceGraph.attr("width") - confidenceMargin.left - confidenceMargin.right,
            confidenceHeight = +confidenceGraph.attr("height") - confidenceMargin.top - confidenceMargin.bottom;

          // Ranges for height and width of graph
          var confidenceX = d3.scaleBand().range([4, confidenceWidth - 4]).padding(0.1),
            confidenceY = d3.scaleLinear().range([confidenceHeight, 15]);

          var confidenceG = confidenceGraph.append("g");

          // Map size of bars to data
          confidenceX.domain(confidenceData.map(function(d) {
            return d.weight;
          }));
          confidenceY.domain([0, d3.max(confidenceData, function(d) {
            return d.count;
          })]);

          var cBrush = d3.brushX() // Create brush overlay
            .extent([
              [1, 10],
              [confidenceWidth, confidenceHeight]
            ])
            .handleSize(0)
            .on("brush", updateBrush)
            .on("end", brushed);

          // Create group for x axis
          confidenceG.append("g")
            .attr("class", "axis axis--x")
            .attr("transform", "translate(0," + confidenceHeight + ")")
            .call(d3.axisBottom(confidenceX).tickSize(0));

          // Draw and style each bar according to weight and count in data
          confidenceG.selectAll(".bar")
            .data(confidenceData)
            .enter().append("rect")
            .attr("class", "bar")
            .attr("x", function(d) {
              return confidenceX(d.weight);
            })
            .attr("y", function(d, i) {
              return confidenceY(d.count);
            })
            .attr("width", confidenceX.bandwidth())
            .attr("height", function(d,i) {
              return confidenceHeight - confidenceY(d.count);
            });

          var cBrushSelection = confidenceG.append("g")
            .attr("class", "brush")
            .call(cBrush);

          //create custom handles
          cBrushSelection.selectAll(".handle-custom")
            .data([{
              type: "w"
            }, {
              type: "e"
            }])
            .enter().append("rect")
            .attr("class", function(d) {
              if (d.type === "e") {
                return "handle-custom handle-e";
              } else {
                return "handle-custom handle-w";
              }
            })
            .attr("width", 4)
            .attr("height", function(d) {
              return confidenceHeight / 2;
            })
            .attr("rx", 2)
            .attr("ry", 2)
            .attr("cursor", "ew-resize")
            .attr("x", function(d) {
              if (d.type === "e") {
                return confidenceWidth - 6;
              } else {
                return 2;
              }
            })
            .attr("y", function(d) {
              return confidenceHeight / 4 + 5;
            });

          //creates brush texts
          cBrushSelection.selectAll("brush-text")
            .data([{
              type: "w",
              confidence: 60
            }, {
              type: "e",
              confidence: 100
            }])
            .enter().append("text")
            .attr("class", function(d) {
              if (d.type === "e") {
                return "brush-text text-e";
              } else {
                return "brush-text text-w";
              }
            })
            .attr("text-anchor", function(d) {
              if (d.type === "e") {
                return "end";
              } else {
                return "start";
              }
            })
            .attr("x", function(d) {
              if (d.type === "e") {
                return confidenceWidth - 6;
              } else {
                return 2;
              }
            })
            .attr("y", 8)
            .text(function(d) {
              return d.confidence + "%";
            });

          cBrushSelection.call(cBrush.move, /*confidenceX.range()*/[confidenceX(60),confidenceWidth]);

          function updateBrush() {
            var brushPositionX = d3.select(".confidence-container .selection").node().getBBox().x,
              brushPositionWidth = d3.select(".confidence-container .selection").node().getBBox().width;
            d3.select(".confidence-container .handle-custom.handle-w").attr("x", function(d) {
              return brushPositionX - 2;
            });
            d3.select(".confidence-container .handle-custom.handle-e").attr("x", function(d) {
              return brushPositionX + brushPositionWidth - 2;
            });

            var s = d3.event.selection || confidenceX.range();
            var convertConfidence = d3.scaleLinear().domain([0, confidenceWidth-4]).range([0, 100]).clamp(true);
            var confidenceMin = Math.round(convertConfidence(s[0]));
            var confidenceMax = Math.round(convertConfidence(s[1]));
            // console.log(confidenceMax);

            d3.select(".confidence-container .brush-text.text-w")
              .attr("x", function(d) {
                return brushPositionX - 2;
              })
              .attr("text-anchor", function(d) {
                if (confidenceMin < 64 && (confidenceMax - confidenceMin) < 7) {
                  return "start";
              } else if (confidenceMin >= 64 && (confidenceMax - confidenceMin) < 7) {
                  return "end";
                } else {
                  return "start";
                }
              })
              .text(function(d) {
                return confidenceMin + "%";
              });
            d3.select(".confidence-container .brush-text.text-e")
              .attr("x", function(d) {
                return brushPositionX + brushPositionWidth - 2;
              })
              .attr("text-anchor", function(d) {
                if (confidenceMax > 97 && (confidenceMax - confidenceMin) < 7) {
                  return "end";
              } else if (confidenceMax <= 97 && (confidenceMax - confidenceMin) < 7) {
                  return "start";
                } else {
                  return "end";
                }
              })
              .text(function(d) {
                return confidenceMax + "%";
              });
          }

          function brushed() {
            // When brush event ends, get values of confidence range and broadcast force layout
            var s = d3.event.selection || confidenceX.range();
            var convertConfidence = d3.scaleLinear().domain([0, confidenceWidth-4]).range([0, 100]);
            var confidenceMin = Math.round(convertConfidence(s[0]));
            var confidenceMax = Math.round(convertConfidence(s[1]));
            scope.$evalAsync(function() {
              scope.config.confidenceMin = confidenceMin;
              scope.config.confidenceMax = confidenceMax;
              scope.$watchCollection('[config.confidenceMin, config.confidenceMax]', function(newValues, oldValues) {
                if (newValues != oldValues) {
                  console.log('brushed with new values');
                  scope.updateNetwork(args);
                }
              })
            });
          }
        }

        function createDateGraph() {
          // Same as above, for date range

          var dateData = countDateFrequency();
          var dateGraph = d3.select('.date-container').append('svg').attr('width', 284).attr('height', 70),
            dateMargin = {
              top: 0,
              right: 0,
              bottom: 10,
              left: 0
            },
            dateWidth = +dateGraph.attr("width") - dateMargin.left - dateMargin.right,
            dateHeight = +dateGraph.attr("height") - dateMargin.top - dateMargin.bottom;

          var dateX = d3.scaleBand().range([4, dateWidth - 4]).padding(0.1),
            dateY = d3.scaleLinear().range([dateHeight, 15]);

          var dateG = dateGraph.append("g");

          dateX.domain(dateData.map(function(d) {
            return d.year;
          }));
          dateY.domain([0, d3.max(dateData, function(d) {
            return d.count;
          })]);

          var dBrush = d3.brushX()
            .extent([
              [1, 10],
              [dateWidth, dateHeight]
            ])
            .handleSize(0)
            .on("brush", updateBrush)
            .on("end", brushed);

          dateG.append("g")
            .attr("class", "axis axis--x")
            .attr("transform", "translate(0," + dateHeight + ")")
            .call(d3.axisBottom(dateX).tickSize(0));

          dateG.selectAll(".bar")
            .data(dateData)
            .enter().append("rect")
            .attr("class", "bar")
            .attr("x", function(d) {
              return dateX(d.year);
            })
            .attr("y", function(d) {
              return dateY(d.count);
            })
            .attr("width", dateX.bandwidth())
            .attr("height", function(d) {
              return dateHeight - dateY(d.count);
            });

          var dBrushSelection = dateG.append("g")
            .attr("class", "brush")
            .call(dBrush);

          //create custom handles
          dBrushSelection.selectAll(".handle-custom")
            .data([{
              type: "w"
            }, {
              type: "e"
            }])
            .enter().append("rect")
            .attr("class", function(d) {
              if (d.type === "e") {
                return "handle-custom handle-e";
              } else {
                return "handle-custom handle-w";
              }
            })
            .attr("width", 4)
            .attr("height", function(d) {
              return dateHeight / 2;
            })
            .attr("rx", 2)
            .attr("ry", 2)
            .attr("cursor", "ew-resize")
            .attr("x", function(d) {
              if (d.type === "e") {
                return dateWidth - 6;
              } else {
                return 2;
              }
            })
            .attr("y", function(d) {
              return dateHeight / 4 + 5;
            });

          //creates brush texts
          dBrushSelection.selectAll("brush-text")
            .data([{
              type: "w",
              year: 1562
            }, {
              type: "e",
              year: 1625
            }])
            .enter().append("text")
            .attr("class", function(d) {
              if (d.type === "e") {
                return "brush-text text-e";
              } else {
                return "brush-text text-w";
              }
            })
            .attr("text-anchor", function(d) {
              if (d.type === "e") {
                return "end";
              } else {
                return "start";
              }
            })
            .attr("x", function(d) {
              if (d.type === "e") {
                return dateWidth - 6;
              } else {
                return 2;
              }
            })
            .attr("y", 8)
            .text(function(d) {
              return d.year;
            });

          dBrushSelection.call(dBrush.move, dateX.range());

          function updateBrush() {
            var brushPositionX = d3.select(".date-container .selection").node().getBBox().x,
              brushPositionWidth = d3.select(".date-container .selection").node().getBBox().width;
            d3.select(".date-container .handle-custom.handle-w").attr("x", function(d) {
              return brushPositionX - 2;
            });
            d3.select(".date-container .handle-custom.handle-e").attr("x", function(d) {
              return brushPositionX + brushPositionWidth - 2;
            });

            var s = d3.event.selection || dateX.range();
            var convertDate = d3.scaleLinear().domain([0, dateWidth-4]).range([startYear, endYear]);
            dateMin = Math.round(convertDate(s[0]));
            dateMax = Math.round(convertDate(s[1]));

            d3.select(".date-container .brush-text.text-w")
              .attr("x", function(d) {
                return brushPositionX - 2;
              })
              .attr("text-anchor", function(d) {
                if (dateMin < 1566 && (dateMax - dateMin) < 11) {
                  return "start";
              } else if (dateMin >= 1566 && (dateMax - dateMin) < 11) {
                  return "end";
                } else {
                  return "start";
                }
              })
              .text(function(d) {
                return dateMin;
              });
            d3.select(".date-container .brush-text.text-e")
              .attr("x", function(d) {
                return brushPositionX + brushPositionWidth - 2;
              })
              .attr("text-anchor", function(d) {
                if (dateMax > 1621 && (dateMax - dateMin) < 11) {
                  return "end";
                } else if (dateMax <= 1621 && (dateMax - dateMin) < 11) {
                  return "start";
                } else {
                  return "end";
                }
              })
              .text(function(d) {
                return dateMax;
              });
          }

          function brushed() {
            var s = d3.event.selection || dateX.range();
            var convertDate = d3.scaleLinear().domain([0, dateWidth-4]).range([startYear, endYear]);
            dateMin = Math.round(convertDate(s[0]));
            dateMax = Math.round(convertDate(s[1]));

            // $state.go('home.forceLayout', {date: dateMin.toString()+','+dateMax.toString()});

            scope.$evalAsync(function() {
              scope.config.dateMin = dateMin;
              scope.config.dateMax = dateMax;
              scope.$watchCollection('[config.dateMin, config.dateMax]', function(newValues, oldValues) {
                if (newValues != oldValues) {
                  console.log('brushed with new values');
                  scope.updateNetwork(args);
                }
              })
            });
          }
        }

        scope.$watch('$stateParams.ids', function(newValue, oldValue) {
          if (scope.config.viewMode !== 'group-force' && scope.config.viewMode !== 'all' && scope.config.viewMode !== 'group-timeline') {
            scope.reloadFilters(scope.data);
          }
        }, true);


      }
    }
  });
