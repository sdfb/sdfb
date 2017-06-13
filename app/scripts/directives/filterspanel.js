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
        // element.text('this is the filtersPanel directive');
        // console.log(scope.data.included);
        var confidenceMin = scope.config.confidenceMin,
          confidenceMax = scope.config.confidenceMax,
          dateMin = scope.config.dateMin,
          dateMax = scope.config.dateMax,
          complexity = scope.config.networkComplexity,
          sourceId = scope.data.data.attributes.primary_people[0],
          sourceNode = scope.data.included.filter(function(d) {
            if (d.id.toString() === sourceId) {
              return d; }; })[0],
          links = [];
        scope.data.data.attributes.connections.forEach(function(c) { links.push(c.attributes) });


        sourceNode = sourceNode.attributes;

        createDensityButtons();
        createConfidenceGraph();
        createDateGraph();

        function showTooltip(d) {
            $('.interaction-info').text(function(){
                if (d == 1) {
                    return 'Source person and 1-degree relationships';
                } else if (d == 1.5) {
                    return 'Relationships among all 1-degree people';
                } else if (d == 1.75) {
                    return 'All 1-degree people and 2-degree people with more than one 1-degree relationship';
                } else if (d == 2) {
                    return 'All people; relationships between 1-degree and 2-degree people only';
                } else {
                    return 'All 1- and 2-degree people and relationships';
                }
            });
        }

        function resetTooltip(d) {
            $('.interaction-info').text('Hover on a value to learn more');
        }

        function createDensityButtons() {
          // Radio buttons for network complexity.
          var complexityForm = d3.select('.density-container').append('form');

          var complexityBox = complexityForm.selectAll('input')
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
            console.log('change');
            complexity = this.value;
            console.log(complexity);
            scope.$evalAsync(function() {
              scope.config.networkComplexity = complexity;
              scope.$broadcast('Update the force layout', {layout: scope.config.viewMode});
            });
          });
        }

        function countConfidenceFrequency() {
          var confidence = d3.range(60, 101);
          var frequencies = {};
          confidence.forEach(function(c) {
            frequencies[c.toString()] = 0;
          });
          links.forEach(function(l) {
            frequencies[l.weight] += 1;
          });
          var data = [];
          for (var x in frequencies) {
            data.push({ 'weight': x, 'count': frequencies[x] });
          }
          return data;
        }

        function countDateFrequency() {
          var years = d3.range(parseInt(sourceNode.birth_year), parseInt(sourceNode.death_year) + 1);
          var frequencies = {};
          years.forEach(function(y) {
            frequencies[y.toString()] = 0;
          });
          years.forEach(function(y) {
            links.forEach(function(l) {
              if (y >= l.start_year && y <= l.end_year) { frequencies[y.toString()] += 1; }
            });
          });
          var data = [];
          for (var x in frequencies) {
            data.push({ 'year': x, 'count': frequencies[x] });
          }
          return data;
        }

        function createConfidenceGraph() {

          var confidenceData = countConfidenceFrequency();
          var confidenceGraph = d3.select('.confidence-container').append('svg').attr('width', 315).attr('height', 70),
            confidenceMargin = { top: 0, right: 15, bottom: 20, left: 15 },
            confidenceWidth = +confidenceGraph.attr("width") - confidenceMargin.left - confidenceMargin.right,
            confidenceHeight = +confidenceGraph.attr("height") - confidenceMargin.top - confidenceMargin.bottom;

          var confidenceX = d3.scaleBand().range([0, confidenceWidth]).padding(0.1),
            confidenceY = d3.scaleLinear().range([confidenceHeight, 0]);

          var confidenceG = confidenceGraph.append("g");

          confidenceX.domain(confidenceData.map(function(d) {
            return d.weight; }));
          confidenceY.domain([0, d3.max(confidenceData, function(d) {
            return d.count; })]);

          var cBrush = d3.brushX()
            .extent([
              [0, 0],
              [confidenceWidth, confidenceHeight]
            ])
            .on("end", brushed);

          confidenceG.append("g")
            .attr("class", "axis axis--x")
            .attr("transform", "translate(0," + confidenceHeight + ")")
            .call(d3.axisBottom(confidenceX).tickValues(["60", "100"]).tickFormat(function(d) {
              return d + "%" }));

          confidenceG.selectAll(".bar")
            .data(confidenceData)
            .enter().append("rect")
            .attr("class", "bar")
            .attr("x", function(d) {
              return confidenceX(d.weight); })
            .attr("y", function(d) {
              return confidenceY(d.count); })
            .attr("width", confidenceX.bandwidth())
            .attr("height", function(d) {
              return confidenceHeight - confidenceY(d.count); });

          confidenceG.append("g")
            .attr("class", "brush")
            .call(cBrush)
            .call(cBrush.move, confidenceX.range());

          function brushed() {
            var s = d3.event.selection || confidenceX.range();
            var convertConfidence = d3.scaleLinear().domain([0, confidenceWidth]).range([60,100]);
            var confidenceMin = Math.round(convertConfidence(s[0]));
            var confidenceMax = Math.round(convertConfidence(s[1]));
            scope.$evalAsync(function() {
              scope.config.confidenceMin = confidenceMin;
              scope.config.confidenceMax = confidenceMax;
              scope.$watchCollection('[config.confidenceMin, config.confidenceMax]', function(newValues, oldValues) {
                if(newValues != oldValues) {
                  console.log('brushed with new values');
                  scope.$broadcast('Update the force layout', {layout: scope.config.viewMode});
                }
              })
            });
          }
        }

        function createDateGraph() {

          var dateData = countDateFrequency();
          var dateGraph = d3.select('.date-container').append('svg').attr('width', 315).attr('height', 70),
            dateMargin = { top: 0, right: 15, bottom: 20, left: 15 },
            dateWidth = +dateGraph.attr("width") - dateMargin.left - dateMargin.right,
            dateHeight = +dateGraph.attr("height") - dateMargin.top - dateMargin.bottom;

          var dateX = d3.scaleBand().range([0, dateWidth]).padding(0.1),
            dateY = d3.scaleLinear().range([dateHeight, 0]);

          var dateG = dateGraph.append("g");

          dateX.domain(dateData.map(function(d) {
            return d.year; }));
          dateY.domain([0, d3.max(dateData, function(d) {
            return d.count; })]);

          var dBrush = d3.brushX()
            .extent([
              [0, 0],
              [dateWidth, dateHeight]
            ])
            .on("end", brushed);

          dateG.append("g")
            .attr("class", "axis axis--x")
            .attr("transform", "translate(0," + dateHeight + ")")
            .call(d3.axisBottom(dateX).tickValues([sourceNode.birth_year, sourceNode.death_year]));

          dateG.selectAll(".bar")
            .data(dateData)
            .enter().append("rect")
            .attr("class", "bar")
            .attr("x", function(d) {
              return dateX(d.year); })
            .attr("y", function(d) {
              return dateY(d.count); })
            .attr("width", dateX.bandwidth())
            .attr("height", function(d) {
              return dateHeight - dateY(d.count); });

          dateG.append("g")
            .attr("class", "brush")
            .call(dBrush)
            .call(dBrush.move, dateX.range());

          function brushed() {
            var s = d3.event.selection || dateX.range();
            var convertDate = d3.scaleLinear().domain([0, dateWidth]).range([sourceNode.birth_year, sourceNode.death_year]);
            dateMin = Math.round(convertDate(s[0]));
            dateMax = Math.round(convertDate(s[1]));

            scope.$evalAsync(function() {
              scope.config.dateMin = dateMin;
              scope.config.dateMax = dateMax;
              scope.$watchCollection('[config.dateMin, config.dateMax]', function(newValues, oldValues) {
                if(newValues != oldValues) {
                  console.log('brushed with new values');
                  scope.$broadcast('Update the force layout', {layout: scope.config.viewMode});
                }
              })
            });
          }
        }

      }
    };
  });
