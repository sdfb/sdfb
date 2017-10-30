'use strict';

/**
 * @ngdoc directive
 * @name redesign2017App.directive:groupTimeline
 * @description
 * # groupTimeline
 */
angular.module('redesign2017App')
  .directive('groupTimeline', ['$state', function($state) {
    return {
      template: '<svg id="group-timeline"></svg>',
      restrict: 'E',
      link: function postLink(scope, element, attrs) {

        var svg = d3.select(element[0]).select('svg'),
          margin = { top: 90, right: 20, bottom: 30, left: 200 },

          // width = +svg.node().getBoundingClientRect().width - margin.left - margin.right,

          width = window.innerWidth - d3.select('.on-the-left').node().getBoundingClientRect().width - 30,
          svgMargin = window.innerWidth - width - margin.right,
          height = +svg.node().getBoundingClientRect().width - margin.top - margin.bottom;

        var primary_people;
        var members;
        var groupInfo;

        // console.log(width);

        var x = d3.scaleLinear()
          .rangeRound([0, width - 210]); // cambiamento provvisorio, serve per non far sforare le timeline oltre lo schermo (quel 200 tiene conto del nome più lungo nel dataset)

        var y = d3.scaleBand()
          .padding(0.1)

        var g = svg.append("g").attr('class', 'g').attr("transform", "translate(" + margin.left + "," + margin.top + ")");

        function terminators(position, type, refX, refY, width) {
          if (!width) { width = 9 }

          if (type == 'AF') {
            refX = (position == 'birth') ? (refX - width / 3) : (refX + width / 3)
            return 'M' + (refX + width / 2) + ' ' + (refY - width / 2) + ' C ' + (refX + width / 4) + ' ' + (refY - width / 2) + ',' + refX + ' ' + (refY - width / 4) + ',' + refX + ' ' + refY + ' S ' + (refX + width / 4) + ' ' + (refY + width / 2) + ',' + (refX + width / 2) + ' ' + (refY + width / 2);

          } else if (type == 'AF/IN') {
            return 'M' + (refX + width / 2) + ' ' + (refY - width / 2) + ' C ' + (refX + width / 4) + ' ' + (refY - width / 2) + ',' + refX + ' ' + (refY - width / 4) + ',' + refX + ' ' + refY + ' S ' + (refX + width / 4) + ' ' + (refY + width / 2) + ',' + (refX + width / 2) + ' ' + (refY + width / 2);

          } else if (type == 'BF') {
            refX = (position == 'birth') ? (refX - width / 3) : (refX + width / 3)
            return 'M' + (refX - width / 2) + ' ' + (refY - width / 2) + ' C ' + (refX - width / 4) + ' ' + (refY - width / 2) + ',' + refX + ' ' + (refY - width / 4) + ',' + refX + ' ' + refY + ' S ' + (refX - width / 4) + ' ' + (refY + width / 2) + ',' + (refX - width / 2) + ' ' + (refY + width / 2);

          } else if (type == 'BF/IN') {
            return 'M' + (refX - width / 2) + ' ' + (refY - width / 2) + ' C ' + (refX - width / 4) + ' ' + (refY - width / 2) + ',' + refX + ' ' + (refY - width / 4) + ',' + refX + ' ' + refY + ' S ' + (refX - width / 4) + ' ' + (refY + width / 2) + ',' + (refX - width / 2) + ' ' + (refY + width / 2);

          } else if (type == 'IN') {
            return 'M' + (refX) + ' ' + (refY - width / 2) + ' L ' + (refX) + ' ' + (refY + width / 2);

          } else if (type == 'CA') {
            return 'M' + refX + ' ' + (refY - width / 2) + ' C ' + (refX - width / 4) + ' ' + (refY - width / 2) + ',' + (refX - width / 2) + ' ' + (refY - width / 4) + ',' + (refX - width / 2) + ' ' + refY + ' S ' + (refX - width / 4) + ' ' + (refY + width / 2) + ',' + refX + ' ' + (refY + width / 2) + ' S ' + (refX + width / 2) + ' ' + (refY + width / 4) + ',' + (refX + width / 2) + ' ' + (refY) + ' S ' + (refX + width / 4) + ' ' + (refY - width / 2) + ',' + (refX) + ' ' + (refY - width / 2) + ' Z';
          }
        }

        function wrap(text, width) {
          text.each(function() {
            var text = d3.select(this),
              words = text.text().split(/\s+/).reverse(),
              word,
              line = [],
              lineNumber = 0,
              lineHeight = 1.5, // ems
              y = text.attr("y"),
              dy = parseFloat(text.attr("dy")),
              tspan = text.text(null).append("tspan").attr("x", 0).attr("y", y).attr("dy", dy + "em");
            while (word = words.pop()) {
              line.push(word);
              tspan.text(line.join(" "));
              if (tspan.node().getComputedTextLength() > width) {
                line.pop();
                tspan.text(line.join(" "));
                line = [word];
                tspan = text.append("tspan").attr("x", 0).attr("y", y).attr("dy", ++lineNumber * lineHeight + dy + "em").text(word);
              }
            }
          });
        }

        function update(data) {

          // console.log(data);
          svg.attr("width", width);
          var numLines = data.map(function(d) { return d.assignementID; }).length;
          svg.attr("height", numLines * 20 + margin.top + margin.bottom);
          svg.style("margin-left", svgMargin + 'px');
          height = +svg.attr("height") - margin.top - margin.bottom;

          var minX = Math.floor(d3.min(data, function(d) { return d.attributes.birth_year }) * 0.1) * 10;
          var maxX = Math.ceil(+d3.max(data, function(d) { return d.attributes.death_year }) * 0.1) * 10;

          // console.log(minX, maxX);
          var amountFactor = 20;
          var amountGuides = (maxX - minX) / amountFactor
          // console.log(amountGuides);

          x.domain([minX, maxX]);
          y.rangeRound([height, 0]).domain(data.map(function(d) { return d.id }));

          g.append("rect")
            .attr('class', 'reset-rect')
            .attr("width", width + margin.left + margin.right)
            .attr("height", height + margin.top + margin.bottom)
            .attr("x", 0 - margin.left)
            .attr("y", 0 - margin.top)
            .on("click", function() {
              console.log("reset")
              d3.selectAll("#group-timeline g.membership").each(function(e) {
                d3.select(this)
                  .classed('selected', false)
                  .transition() // apply a transition
                  .duration(500) // apply it over 2000 milliseconds
                  .attr("transform", "translate(0, " + (y(e.id) + y.bandwidth() / 2) + ")")
              })
              svg.attr("height", numLines * 20 + margin.top + margin.bottom);
              // update selction and trigger event for other directives
              // scope.currentSelection = {};
              // scope.$apply(); // no need to trigger events, just apply
            });

          var person = g.selectAll("#group-timeline .membership");

          for (var i = 1; i <= amountGuides; i++) {
            g.append("line")
              .attr("class", "guide")
              .attr("x1", x(minX + i * amountFactor))
              .attr("x2", x(minX + i * amountFactor))
              .attr("y1", 35 - margin.top)
              .attr("y2", height - 10)
            g.append("text")
              .attr("class", "guide-label")
              .attr('x', x(minX + i * amountFactor))
              .attr('y', 25 - margin.top)
              .text(minX + i * amountFactor)
          }

          g.append("line")
            .attr("class", "guide-group start")
            .attr("x1", x(groupInfo.start_year))
            .attr("x2", x(groupInfo.start_year))
            .attr("y1", 0 - margin.top)
            .attr("y2", height + margin.bottom)

          g.append("line")
            .attr("class", "guide-group end")
            .attr("x1", x(groupInfo.end_year))
            .attr("x2", x(groupInfo.end_year))
            .attr("y1", 0 - margin.top)
            .attr("y2", height + margin.bottom)

          g.append("text")
            .attr("class", "group-name")
            .attr('x', function() {
              return x(groupInfo.start_year + (groupInfo.end_year - groupInfo.start_year) / 2)
            })
            .attr('y', -20)
            // .text(groupInfo.name)

          person = person.data(data, function(d) { return d.id; });
          person.exit().remove();
          person = person.enter().append("g")
            .merge(person)
            .attr('class', 'membership')
            .attr("transform", function(d) {
              return "translate(0, " + (y(d.id) + y.bandwidth() / 2) + ")"
            })
            .on("click", function(d, i) {

              d3.selectAll("#group-timeline g.membership").each(function(e, j) {
                d3.select(this).classed('selected', false);
                if (j < i) {
                  d3.select(this)
                    .attr("transform", d3.select(this).attr("transform"))
                    .transition() // apply a transition
                    .duration(500) // apply it over 2000 milliseconds
                    .attr("transform", "translate(0, " + ((y(e.id) + y.bandwidth() / 2) + 110) + ")")
                } else if ((j > i)) {
                  d3.select(this)
                    .transition() // apply a transition
                    .duration(500) // apply it over 2000 milliseconds
                    .attr("transform", "translate(0, " + (y(e.id) + y.bandwidth() / 2) + ")")
                }
              })
              d3.select(this)
                .classed('selected', true)
                .transition() // apply a transition
                .duration(500) // apply it over 2000 milliseconds
                .attr("transform", "translate(0, " + (y(d.id) + 20 + y.bandwidth() / 2) + ")");

              svg.attr("height", numLines * 20 + margin.top + margin.bottom + 200); //Make svg big enough for expanded item
            })

          person.append("rect")
            .attr('class', 'active-area')
            .attr('width', width + 200)
            .attr('height', y.bandwidth())
            .attr('x', -190)
            .attr('y', -(y.bandwidth() / 2))

          person.append('text')
            .attr('class', 'name')
            .attr('x', 0)
            .attr('y', y.bandwidth() / 4)
            .text(function(d) { return d.attributes.name })

          person.append('text')
            .attr('class', 'historical-significance')
            .attr('x', 0)
            .attr('y', y.bandwidth())
            .attr('dy', .85)
            .text(function(d) { return d.attributes.historical_significance });

          d3.selectAll('#group-timeline .historical-significance').call(wrap, 160);

          var timelineButton = person.append('g')
            .attr('class', 'timeline-button');

          timelineButton.append('rect')

            .attr('class', 'timeline-button-rect')
            .attr('x', -115)
            .attr('y', y.bandwidth() + 38)
            .attr('width', 95)
            .attr('height', 24)
            .attr('rx', 12)
            .attr('ry', 12);
            // .text('Hooke Layout')


          timelineButton.append('text')
            .data(data, function(d) { return d.id; })
            .attr('class', 'timeline-button-text')
            .attr('x', -40)
            .attr('y', y.bandwidth() + 53)
            .attr('text-anchor', 'end')
            .text('Visualize')
            .on('click', function(d) {
              // scope.selectedPerson(d);
              // scope.$apply(function() {
              //   scope.config.viewObject = 0;
              // });
              $state.go('home.visualization', {ids: d.id});
            });

          person.append('text')
            .attr('class', 'birth-label historical-significance')
            .attr('x', function(d) { return x(d.attributes.birth_year) })
            .attr('y', y.bandwidth() + 9)
            .text(function(d) {
              var myLabel = 'Born ' + d.attributes.birth_year_type + ' ' + d.attributes.birth_year;
              return myLabel;
            });

          person.append('text')
            .attr('class', 'death-label historical-significance')
            .attr('x', function(d) { return x(d.attributes.death_year) })
            .attr('y', y.bandwidth() + 9)
            .text(function(d) {
              var myLabel = 'Dead ' + d.attributes.death_year_type + ' ' + d.attributes.death_year;
              return myLabel;
            });

          person.append('text')
            .attr('class', 'membership-duration historical-significance')
            .attr('x', function(d) { return x(groupInfo.start_year + (groupInfo.end_year - groupInfo.start_year) / 2) })
            .attr('y', -y.bandwidth())
            .style('text-anchor', 'middle')
            .text(function(d) {
              var myLabel = 'Member from ' + d.attributes.start_year + ' to ' + d.attributes.end_year + '.';
              return myLabel;
            });



          person.append('path')
            .attr('class', 'life')
            .attr('d', function(d) {
              return 'M' + x(d.attributes.birth_year) + ',' + '0' + ' L' + (x(d.attributes.death_year)) + ',' + '0';
            });

          person.append('path')
            .attr('class', function(d) {
              var classes = (d.attributes.birth_year_type == 'CA') ? 'terminator birth filled' : 'terminator birth'
              return classes
            })
            .attr('d', function(d) { return terminators('birth', d.attributes.birth_year_type, x(d.attributes.birth_year), 0) });

          person.append('path')
            .attr('class', function(d) {
              var classes = (d.attributes.death_year_type == 'CA') ? 'terminator death filled' : 'terminator death'
              return classes
            })
            .attr('d', function(d) { return terminators('birth', d.attributes.death_year_type, x(d.attributes.death_year), 0) });

          // Will not work until API is updated.
          person.append('path')
            .attr('class', 'membership')
            .attr('d', function(d) {
              return 'M' + x(d.attributes.start_year) + ',' + 0 + ' L' + (x(d.attributes.end_year)) + ',' + 0;
            });
        }

        // action triggered from the controller
        scope.$watch('data', function(newValue, oldValue) {
          if (scope.config.viewMode === 'group-timeline') {
            var json = newValue.data;
            groupInfo = json.data[0].attributes;
            groupInfo.id = json.data[0].id;

            members = json.includes;
            members.forEach(function(m, i) {
              m.attributes.start_year = groupInfo.people[i].start_year;
              m.attributes.start_year_type = groupInfo.people[i].start_year_type;
              m.attributes.end_year = groupInfo.people[i].end_year;
              m.attributes.end_year_type = groupInfo.people[i].end_year_type;
            })

            update(members);
          }
        });

      }
    };
  }]);
