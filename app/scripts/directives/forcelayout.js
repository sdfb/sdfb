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
				// 	var term = document.getElementById('searchTerm').value;
				// 	var selected = container.selectAll('.node').filter(function(d, i) {
				// 		return d.name.toLowerCase().search(term.toLowerCase()) == -1;
				// 	});
				// 	selected.style('opacity', '0');
				// 	var link = container.selectAll('.link');
				// 	link.style('stroke-opacity', '0');
				// 	d3.selectAll('.node').transition()
				// 		.duration(5000)
				// 		.style('opacity', '1');
				// 	d3.selectAll('.link').transition().duration(5000).style('stroke-opacity', '0.6');
				// }
				// Create form for search (see function below).
				// var search = d3.select("div#tools").append('form').attr('onsubmit', 'return false;');
				// var box = search.append('input')
				// 	.attr('type', 'text')
				// 	.attr('id', 'searchTerm')
				// 	.attr('placeholder', 'Type to search...');
				// var button = search.append('input')
				// 	.attr('type', 'button')
				// 	.attr('value', 'Search')
				// 	.on('click', function() {
				// 		searchNodes();
				// 	});

				// Confidence
				// A slider that removes nodes and edges below the input confidenceMin.
				// var confidenceSlider = d3.select('div#tools').append('div').text('Confidence Estimate (1- and 2-degree only): ');

				// var confidenceSliderLabel = confidenceSlider.append('label')
				// 	.attr('for', 'confidenceMin')
				// 	.attr('id', 'confidenceLabel')
				// 	.text('60');
				// var confidenceSliderMain = confidenceSlider.append('input')
				// 	.attr('type', 'range')
				// 	.attr('min', 60)
				// 	.attr('max', 100)
				// 	.attr('value', 60)
				// 	.attr('id', 'confidenceMin')
				// 	.style('width', '50%')
				// 	.style('display', 'block')
				// 	.on('input', function() {
				// 		confidenceMin = this.value;

				// 		d3.select('#confidenceLabel').text(confidenceMin);

				// 		update(confidenceMin, complexity);

				// 	});

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
				// Radio buttons for network complexity.
				// var complexityForm = d3.select('div#tools').append('form')
				// var complexityLabel = complexityForm.append('label')
				// 	.text('Network Complexity: ' + complexity + " ")
				// 	.attr('id', 'complexityLabel');
				// var complexityButtons = complexityForm.selectAll('input')
				// 	.data(['1', '1.5', '1.75', '2', '2.5'])
				// 	.enter().append('input')
				// 	.attr('type', 'radio')
				// 	.attr('name', 'complexity')
				// 	.attr('checked', function(d) {
				// 		if (d == complexity) {
				// 			return 'checked';
				// 		}
				// 	})
				// 	.attr('value', function(d) {
				// 		return d;
				// 	});
				// complexityButtons.on('change', function() {
				// 	complexity = this.value;
				// 	d3.select("#complexityLabel").text("Network Complexity: " + complexity + " ");
				// 	update(confidenceMin, complexity);
				// });


				// Draw curved edges
				function linkArc(d) {
					var dx = d.target.x - d.source.x,
						dy = d.target.y - d.source.y,
						dr = Math.sqrt(dx * dx + dy * dy);
					return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
				}
				// A function to handle click toggling based on neighboring nodes.
				function toggleClick(d, newLinks) {
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

					if (toggle == 0) {
						// recursivePulse(d);
						// Ternary operator restyles links and nodes if they are adjacent.
						d3.selectAll('.link').style('stroke', function(l) {
							return l.target == d || l.source == d ? 1 : '#D3D3D3';
						});
						d3.selectAll('.node')
							.classed('faded', function(n) {
								if (n.id in connectedNodes) {
									return false
								} else {
									return true;
								};
							})
							.classed('focussed', function(n) {
								if (n.id in connectedNodes) {
									return true
								} else {
									return false;
								};
							})

						// Log information when node is clicked
						console.log(d, d.attributes.groups)

						scope.currentSelection.person1 = {id:d.id, name:d.attributes.name, historical_significance:d.attributes.historical_significance, birth_year:d.attributes.birth_year, death_year:d.attributes.death_year};
						scope.currentSelection.person1 = d;
						scope.$broadcast('selectionUpdated', scope.currentSelection);
						// scope.$apply();
						// console.log('currentSelection',scope.currentSelection);

							// d3.select('div#tools').append('span').text("Name: " + d.name + "  |  Historical Significance: " + d.historical_significance + "  |  Lived: " + d.birth_year + "-" + d.death_year);
						toggle = 1;
					}
				}

				svg.append('rect')
					.attr('width', '100%')
					.attr('height', '100%')
					.attr('fill', 'transparent')
					.on('click', function() {
						if (toggle == 1) {
							// Restore nodes and links to normal opacity. (see toggleClick() below)
							d3.selectAll('.link').style('stroke', '#000');
							// d3.select('[pulse="true"]').transition().duration(200).style('opacity', 1);
							d3.selectAll('.node')
								// .attr('pulse', false)
								.classed('faded', false)
								.classed('focused', false);

							// reset group bar
							d3.selectAll('.group').classed('active', false);
							d3.selectAll('.group').classed('unactive', false);
							// d3.selectAll('span').remove();
							scope.currentSelection = {};
							scope.$apply();
							// console.log('currentSelection',scope.currentSelection);
							toggle = 0;
						}
					});
				// Zooming function translates the size of the svg container.
				function zoomed() {
					container.attr("transform", "translate(" + d3.event.transform.x + ", " + d3.event.transform.y + ") scale(" + d3.event.transform.k + ")");
				}
				// Call zoom for svg container.
				svg.call(d3.zoom().on('zoom', zoomed)); //.on("dblclick.zoom", null);

				var container = svg.append('g');

				// Toggle for ego networks on click (below).
				var toggle = 0;

				var link = container.append("g")
					.attr("class", "links")
					.selectAll(".link"),
					node = container.append("g")
					.attr("class", "nodes")
					.selectAll(".node");

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
				json.data.attributes.connections.forEach(function(c){ links.push(c.attributes)});
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
					.force("charge", d3.forceManyBody().strength([-500])) //.distanceMax([500]))
					.force("center", d3.forceCenter(width / 2, height / 2))
					.force("collide", d3.forceCollide().radius(21))//function(d) {
						// return degreeSize(d.attributes.degree) + 1;
					// }))
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

					// Data join with only those new links and corresponding nodes.
					link = link.data(newLinks, function(d) {
						return d.source.id + ', ' + d.target.id;
					});
					link.exit().remove();
					var linkEnter = link.enter().append('path')
						.attr('class', 'link');

					link = linkEnter.merge(link)
						// .attr('class', 'link')
						.attr("d", linkArc)
						.attr('class', function(l) {
							if (l.altered == true) {
								return 'link altered';
							} else {
								return 'link';
							}
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

					node.attr('r', 20);//function(d) {
					// 	return degreeSize(d.attributes.degree);
					// });

					node = nodeEnter.merge(node)
						.attr('r', 20)//function(d) {
						// 	return degreeSize(d.attributes.degree);
						// })
						// .attr("fill", function(d) { return color(d.distance); })
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

					//Update legend too
					scope.sizeMin = degreeSize.domain()[0];
					scope.sizeMax = degreeSize.domain()[1]
				}

				update(confidenceMin, confidenceMax, dateMin, dateMax, complexity);

				// update triggered from the controller
				scope.$on('force layout update', function(event, args) {
					console.log(event, args);
					update(confidenceMin, confidenceMax, dateMin, dateMax, complexity);
				});

				var data4groups = scope.data.included
				var listGroups = [];
				data4groups.forEach(function(d){
					if (d.attributes.groups) {
						d.attributes.groups.forEach(function(e){
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
				arr.sort(function(a, b){
				   return d3.descending(a.value, b.value);
				})

				// log the outcome in the scope
				// console.log(arr);

				// using p-quantile for understanding how to cluster smaller goups
				// arr = _.map(arr, function(d){return d.value})
				// console.log(arr)
				// console.log(d3.quantile(arr, 0.25))

				var cutAt = 20;
				var groupsBar = _.slice(arr, 0, cutAt);
				var otherGroups = _.slice(arr, cutAt);
				var othersValue = 0;
				otherGroups.forEach(function(d){
					othersValue += d.value;
				});
				groupsBar.push({'groupId': 'others', 'value': othersValue});
				// console.log(groupsBar);
				
				scope.groups.groupsBar = groupsBar;
				scope.groups.otherGroups = otherGroups;
				// scope.$apply();

			}
		};
	});