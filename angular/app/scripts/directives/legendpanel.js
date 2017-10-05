'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:legendPanel
 * @description
 * # legendPanel
 */
angular.module('redesign2017App')
  .directive('legendPanel', function () {
    return {
      templateUrl: './views/legend.html',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {
        // element.text('this is the legendPanel directive');
        if (scope.config.viewMode === 'all') {
          var sizeScale = d3.scaleLinear()
            .range([8, 30]);

          var sizeEdge = d3.scaleLinear()
            .range([1, 10]);

          var nodes = scope.data.included;

          var maxDegree = d3.max(nodes, function(d) { return d.attributes.degree; });
          var minDegree = d3.min(nodes, function(d) { return d.attributes.degree; });
          sizeScale.domain([minDegree, maxDegree]);
          var links = [];
          scope.data.data.attributes.connections.forEach(function(l) {
            links.push({
              'type': l.type,
              'source': l.attributes.source,
              'target': l.attributes.target,
              'weight': l.attributes.weight
            })
          })
          console.log(links);
          var minWeight = d3.min(links, function(d) { return d.weight });
          var maxWeight = d3.max(links, function(d) { return d.weight });
          sizeEdge.domain([minWeight, maxWeight]);

          var extentNodes = d3.extent(nodes, function(d) { return d.attributes.degree; }),
              extentEdges = d3.extent(links, function(d) { return d.weight; });

          var sizeLegend = d3.select(element[0])//.select('.legend-panel div .legend-size-squares')
              .selectAll('.white-square')
              .data(extentNodes);

          console.log(element[0]);

          var sizeLegendBox = sizeLegend.enter()
              .merge(sizeLegend);

          sizeLegendBox.append('div')
              .classed('white-square', true)
              .style("width", function(d) { return Math.floor((2 * sizeScale(d)) / Math.sqrt(2)) + 'px'; })
              .style("height", function(d) { return Math.floor((2 * sizeScale(d)) / Math.sqrt(2)) + 'px'; })
              .style("margin", function(d,i) { return i == 0 ? "0 24px 0 0" : "0 0 0 24px"; })
              .style("order", function(d,i) { return i == 0 ? 1 : 2; });

          sizeLegendBox.append('div')
              .classed('legend-text', true)
              .text(function(d){ return d; })
              .style("margin", "0 12px")
              .style("order", function(d,i){ return i == 0 ? 0 : 4; });

          sizeLegend.exit().remove();


          var weightLegend = d3.select(element[0])//'.legend-size-edges')
              .selectAll('.edge-line')
              .data(extentEdges);

          var weightLegendBox = weightLegend.enter()
              .merge(weightLegend);

          weightLegendBox.append('div')
              .classed('edge-line', true)
              .style("width", function(d) { return Math.floor(sizeEdge(d)) + 'px'; })
              .style("height", '30px')
              .style("order", function(d,i) { return i == 0 ? 1 : 2; });

          weightLegendBox.append('div')
              .classed('legend-text centered', true)
              .text(function(d){ return d; })
              .style("order", function(d,i){ return i == 0 ? 0 : 4; });

          weightLegend.exit().remove();
        }
      }
    };
  });
