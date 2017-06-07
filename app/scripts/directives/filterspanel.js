'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:filtersPanel
 * @description
 * # filtersPanel
 */
angular.module('redesign2017App')
  .directive('filtersPanel', function () {
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
        sourceNode = scope.data.included.filter(function(d) { if (d.id.toString() === sourceId) {return d;};})[0],
        links = [];
        scope.data.data.attributes.connections.forEach(function(c) { links.push(c.attributes) });


        sourceNode = sourceNode.attributes;

        createDensityButtons();
        createConfidenceGraph();
        createDateGraph();

        function createDensityButtons() {
          // Radio buttons for network complexity.
          var complexityForm = d3.select(element[0]).append('form')
          var complexityLabel = complexityForm.append('label')
           .text('Visual Density: ');
          var complexityButtons = complexityForm.selectAll('input')
           .data(['1', '1.5', '1.75', '2', '2.5'])
           .enter().append('input')
           .attr('type', 'radio')
           .attr('name', 'complexity')
           .attr('checked', function(d) {
             if (d == complexity) {
               return 'checked';
             }
           })
           .attr('value', function(d) {
             return d;
           });
          complexityButtons.on('change', function() {
           complexity = this.value;
           scope.config.networkComplexity = complexity;
           scope.$apply();
          //  console.log(scope.config.networkComplexity);
          });
        }

        function countConfidenceFrequency() {
          var confidence = d3.range(60,101);
          var frequencies = {};
          confidence.forEach(function(c){
            frequencies[c.toString()] = 0;
          });
          links.forEach(function(l){
            frequencies[l.weight] += 1;
          });
          var data = [];
          for (var x in frequencies) {
            data.push({'weight': x, 'count':frequencies[x]});
          }
          return data;
        }

        function countDateFrequency() {
          var years = d3.range(parseInt(sourceNode.birth_year),parseInt(sourceNode.death_year)+1);
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
            data.push({'year': x, 'count':frequencies[x]});
          }
          return data;
        }

        function createConfidenceGraph() {

          var confidenceData = countConfidenceFrequency();
          var confidenceGraph = d3.select(element[0]).append('svg').attr('width', 300).attr('height', 100),
              confidenceMargin = {top: 10, right: 10, bottom: 30, left: 10},
              confidenceWidth = +confidenceGraph.attr("width") - confidenceMargin.left - confidenceMargin.right,
              confidenceHeight = +confidenceGraph.attr("height") - confidenceMargin.top - confidenceMargin.bottom;

          var confidenceX = d3.scaleBand().rangeRound([0, confidenceWidth]).padding(0.1),
              confidenceY = d3.scaleLinear().rangeRound([confidenceHeight, 0]);

          var confidenceG = confidenceGraph.append("g")
              .attr("transform", "translate(" + confidenceMargin.left + "," + confidenceMargin.top + ")");

          confidenceX.domain(confidenceData.map(function(d) { return d.weight; }));
          confidenceY.domain([0, d3.max(confidenceData, function(d) { return d.count; })]);

          var cBrush = d3.brushX()
            .extent([[0, 0], [confidenceWidth, confidenceHeight]])
            .on("end", brushed);

          confidenceG.append("g")
              .attr("class", "axis axis--x")
              .attr("transform", "translate(0," + confidenceHeight + ")")
              .call(d3.axisBottom(confidenceX).tickValues(["60", "100"]).tickFormat(function(d){return d + "%"}));

          confidenceG.selectAll(".bar")
            .data(confidenceData)
            .enter().append("rect")
              .attr("class", "bar")
              .attr("x", function(d) { return confidenceX(d.weight); })
              .attr("y", function(d) { return confidenceY(d.count); })
              .attr("width", confidenceX.bandwidth())
              .attr("height", function(d) { return confidenceHeight - confidenceY(d.count); });

          confidenceG.append("g")
              .attr("class", "brush")
              .call(cBrush)
              .call(cBrush.move, confidenceX.range());

          function brushed() {
            var s = d3.event.selection || confidenceX.range();
            var eachBand = confidenceX.step();
            var marginInterval = confidenceMargin.right/eachBand
            var minIndex = Math.round((s[0] / eachBand) - marginInterval);
            var maxIndex = Math.round((s[1] / eachBand) - marginInterval);
            var confidenceMin = confidenceX.domain()[minIndex] || "60";
            var confidenceMax = confidenceX.domain()[maxIndex] || "100";
            scope.config.confidenceMin = confidenceMin;
            scope.config.confidenceMax = confidenceMax;
            // update(confidenceMin, confidenceMax, dateMin, dateMax, complexity)
          }
         }

        function createDateGraph() {

           var dateData = countDateFrequency();
           var dateGraph = d3.select(element[0]).append('svg').attr('width', 300).attr('height', 100),
               dateMargin = {top: '10', right: '10', bottom: '30', left: '10'},
               dateWidth = +dateGraph.attr("width") - dateMargin.left - dateMargin.right,
               dateHeight = +dateGraph.attr("height") - dateMargin.top - dateMargin.bottom;

           var dateX = d3.scaleBand().rangeRound([0, dateWidth]).padding(0.1),
               dateY = d3.scaleLinear().rangeRound([dateHeight, 0]);

           var dateG = dateGraph.append("g")
               .attr("transform", "translate(" + dateMargin.left + "," + dateMargin.top + ")");

           dateX.domain(dateData.map(function(d) { return d.year; }));
           dateY.domain([0, d3.max(dateData, function(d) { return d.count; })]);

           var dBrush = d3.brushX()
             .extent([[0, 0], [dateWidth, dateHeight]])
             .on("end", brushed);

           dateG.append("g")
               .attr("class", "axis axis--x")
               .attr("transform", "translate(0," + dateHeight + ")")
               .call(d3.axisBottom(dateX).tickValues([sourceNode.birth_year, sourceNode.death_year]));

           dateG.selectAll(".bar")
             .data(dateData)
             .enter().append("rect")
               .attr("class", "bar")
               .attr("x", function(d) { return dateX(d.year); })
               .attr("y", function(d) { return dateY(d.count); })
               .attr("width", dateX.bandwidth())
               .attr("height", function(d) { return dateHeight - dateY(d.count); });

           dateG.append("g")
               .attr("class", "brush")
               .call(dBrush)
               .call(dBrush.move, dateX.range());

           function brushed() {
             var s = d3.event.selection || dateX.range();
             var eachBand = dateX.step();
             var marginInterval = dateMargin.right/eachBand
             var minIndex = Math.round((s[0] / eachBand) - marginInterval);
             var maxIndex = Math.round((s[1] / eachBand) - marginInterval);
             var dateMin = dateX.domain()[minIndex] || sourceNode.birth_year;
             var dateMax = dateX.domain()[maxIndex] || sourceNode.death_year;
             scope.config.dateMin = dateMin;
             scope.config.dateMax = dateMax;
            //  update(confidenceMin, confidenceMax, dateMin, dateMax, complexity)
           }
          }
      }
    };
  });
