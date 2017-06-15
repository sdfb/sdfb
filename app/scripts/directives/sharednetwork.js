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

        var simulation = d3.forceSimulation()
          .force("link", d3.forceLink().id(function(d) {
            return d.id;
          }))
          .force("charge", d3.forceManyBody())
          .force("center", d3.forceCenter(width / 2, height / 2));

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

        function updateSharedNetwork(graph) {

        	// Create array of links
            graph.links = [];
            graph.data.attributes.connections.forEach(function(d){
            	var linkObject = {};
            	linkObject.id = d.id;
            	linkObject.type = d.type;
            	linkObject.source = d.attributes.source;
            	linkObject.target = d.attributes.target;
            	linkObject.attributes = d.attributes;
            	graph.links.push(linkObject);
            });
            // Create array of nodes
            graph.nodes = graph.included;

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

          simulation
            .nodes(graph.nodes)
            .on("tick", ticked);

          simulation.force("link")
            .links(graph.links);

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
