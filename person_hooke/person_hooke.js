
var svg = d3.select("svg"),
    width = +svg.attr("width"),
    height = +svg.attr("height");

var graph;

svg.append('rect')
    .attr('width', '100%')
    .attr('height', '100%')
    .attr('fill', '#FFFFFF');

// Call zoom for svg container.
svg.call(d3.zoom().on('zoom', zoomed));//.on("dblclick.zoom", null);

var M = 50;

var container = svg.append('g');

// Create form for search (see function below).
var search = d3.select("div#tools").append('form').attr('onsubmit', 'return false;');

var color = d3.scaleOrdinal()
    .domain([true,false])
    .range(['#1253a0','#87a9cf']);

var degreeSize = d3.scaleLinear()
    .domain([0,500])
    .range([10,35]);

var box = search.append('input')
	.attr('type', 'text')
	.attr('id', 'searchTerm')
	.attr('placeholder', 'Type to search...');

var button = search.append('input')
	.attr('type', 'button')
	.attr('value', 'Search')
	.on('click', function () { searchNodes(); });

// Toggle for ego networks on click (below).
var toggle = 0;

var link = container.append("g")
    .attr("class", "links")
  .selectAll(".link"),
    node = container.append("g")
      .attr("class", "nodes")
    .selectAll(".node");


d3.json("baconnetwork.json", function(error, json) {
  if (error) throw error;

  graph = json;

  update(graph.nodes, graph.links);

});

	// A slider that removes nodes and edges below the input threshold.
var confidenceSlider = d3.select('div#tools').append('div').text('Confidence Estimate (1- and 2-degree only): ');

var confidenceSliderLabel = confidenceSlider.append('label')
	.attr('for', 'threshold')
  .attr('id', 'confidenceLabel')
	.text('60');
var confidenceSliderMain = confidenceSlider.append('input')
	.attr('type', 'range')
	.attr('min', 60)
	.attr('max', 100)
	.attr('value', 60)
	.attr('id', 'threshold')
	.style('width', '50%')
	.style('display', 'block')
	.on('input', function () {
		var threshold = this.value;

		d3.select('#confidenceLabel').text(threshold);

		// Find the graph.links that are at or above the threshold.
		var newLinks = [];
		graph.links.forEach( function (d) {
			if (d.weight >= threshold) {
				newLinks.push(d);
			};
		});

		var newNodes = [];
		graph.nodes.forEach( function(d) {
			newLinks.forEach( function(l) {
				if (l.source == d || l.target == d) { newNodes.push(d); };
			});
		});

		newNodes = Array.from(new Set(newNodes));

    update(newNodes, newLinks);

	});

  // Radio buttons for network complexity.

var complexityForm = d3.select('div#tools').append('form')

var complexityLabel = complexityForm.append('label')
    .text('Network Complexity: 2.5 ')
    .attr('id', 'complexityLabel');

var complexityButtons = complexityForm.selectAll('input')
    .data(['1','1.5','1.75','2','2.5'])
    .enter().append('input')
    .attr('type', 'radio')
    .attr('name', 'complexity')
    .attr('value', function(d) {return d;})
    .attr('id', function(d) {return 'complexity'+d;});

complexityButtons.on('change', function () {

    var complexity = this.value;

    d3.select("#complexityLabel").text("Network Complexity: "+complexity+" ");

    if (complexity == 1) {
      var newNodes = graph.nodes.filter(function(d) { if (d.one_degree == true) {return d;}; });
      var newLinks = graph.links.filter(function(l) { if (l.source.is_source == true || l.target.is_source == true) {return l;}; });
      update(newNodes, newLinks);
    }

    if (complexity == 1.5) {
      var newNodes = graph.nodes.filter(function(d) { if (d.one_degree == true) {return d;}; });
      var newLinks = graph.links.filter(function(l) { if (l.source.one_degree == true && l.target.one_degree == true) {return l;}; });
      update(newNodes, newLinks);
    }

    if (complexity == 1.75) {
      var newNodes = [];
      graph.nodes.forEach(function(d) {
        if (d.one_degree == true) {newNodes.push(d);}
        else if (d.one_degree == false) {
          count = 0
          graph.links.forEach(function(l){
            if (l.source.id == d.id && l.target.one_degree == true) { count += 1; }
            else if (l.target.id == d.id && l.source.one_degree == true) { count += 1; }
          });
          if (count >= 2) {newNodes.push(d);}
        }
      });
      var newLinks = graph.links.filter(function(l) { if (newNodes.indexOf(l.source) != -1 && newNodes.indexOf(l.target) != -1) {return l;}; });
      update(newNodes, newLinks);
    }

    if (complexity == 2) {
      var newLinks = graph.links.filter(function(l) { if (l.source.one_degree == true || l.target.one_degree == true) {return l;}; });
      update(graph.nodes, newLinks);
    }

    if (complexity == 2.5) { update(graph.nodes, graph.links); }

});

function update(newNodes, newLinks) {

  d3.select('.source-node').remove();

  var simulation = d3.forceSimulation(newNodes)
      // .velocityDecay(.5)
      .force("link", d3.forceLink(newLinks).id(function(d) { return d.id; }))
      .force("charge", d3.forceManyBody().strength([-300]))//.distanceMax([500]))
      .force("center", d3.forceCenter(width / 2, height / 2))
      .force("x", d3.forceX())
      .force("y", d3.forceY())
      .stop();

  for (var i = 0, n = Math.ceil(Math.log(simulation.alphaMin()) / Math.log(1 - simulation.alphaDecay())); i < n; ++i) {
    simulation.tick();
  }
  // Data join with only those new links and corresponding nodes.
  link = link.data(newLinks, function(d) {return d.source.id + ', ' + d.target.id;});
  link.exit().remove();
  var linkEnter = link.enter().append('path')
    .attr('class', 'link');
      link = linkEnter.merge(link)
      .attr("d", function(d) {
              return draw_curve(d.source.x, d.source.y, d.target.x, d.target.y, M);
          })
      .attr('stroke-opacity', function(l) { if (l.altered == true) { return 1;} else {return .35;} });

  // When adding and removing nodes, reassert attributes and behaviors.
  node = node.data(newNodes, function(d) {return d.id;})
  .attr("cx", function(d) { return d.x; })
  .attr("cy", function(d) { return d.y; });
  node.exit().remove();
  var nodeEnter = node.enter().append('circle')
  .attr('r', function(d) { return degreeSize(d.degree);})
  // Color by degree centrality calculation in NetworkX.
  .attr("fill", function(d) { return color(d.one_degree); })
    .attr('class', 'node')
    .attr('id', function(d) { return "n" + d.id.toString(); })
    .attr("cx", function(d) { return d.x; })
    .attr("cy", function(d) { return d.y; })
    .attr("is_source", function(d) {return d.is_source;})
    // On click, toggle ego networks for the selected node. (See function above.)
    .on('click', function(d) { toggleClick(d); });

  node = nodeEnter.merge(node);

    node.append("title")
        .text(function(d) { return d.name; });

  d3.select('.nodes').insert('circle', '[is_source="true"]')
    .attr('r', degreeSize(d3.select('[is_source="true"]').data()[0].degree) + 7)
    .attr('fill', 'orange')//color(d3.select('[is_source="true"]').data()[0].one_degree))
    .attr('class', 'source-node')
    .attr("cx", d3.select('[is_source="true"]').data()[0].x)
    .attr("cy", d3.select('[is_source="true"]').data()[0].y);
}

// A function to handle click toggling based on neighboring graph.nodes.
function toggleClick(d) {


  // Make object of all neighboring graph.nodes.
   connectedNodes = {};
   connectedNodes[d.id] = true;
   graph.links.forEach(function(l) {
     if (l.source.id == d.id) { connectedNodes[l.target.id] = true; }
     else if (l.target.id == d.id) { connectedNodes[l.source.id] = true; };
   });

      if (toggle == 0) {
        recursivePulse(d);
        // Ternary operator restyles graph.links and graph.nodes if they are adjacent.
        d3.selectAll('.link').style('stroke', function (l) {
          return l.target == d || l.source == d ? 1 : '#D3D3D3';
        });
        d3.selectAll('.node').style('fill', function (n) {
          if (n.id in connectedNodes) { return color(n.one_degree); }
          else { return '#D3D3D3'; };
        });

    // Show information when node is clicked
    d3.select('div#tools').append('span').text("Name: " + d.name + "  |  Historical Significance: " + d.historical_significance + "  |  Lived: " + d.birth_year + "-" + d.death_year);
        toggle = 1;
      }
      else {
        // Restore graph.nodes and graph.links to normal opacity.
        d3.selectAll('.link').style('stroke', '#000');
        d3.selectAll('.node').style('fill', function(d) { return color(d.one_degree); });
        d3.select('#n' + d.id.toString()).transition().duration(200).style('opacity', '1');
        d3.selectAll('span').remove();
        toggle = 0;
      }
}

// Zooming function translates the size of the svg container.
function zoomed() {
	  container.attr("transform", "translate(" + d3.event.transform.x + ", " + d3.event.transform.y + ") scale(" + d3.event.transform.k + ")");
}

// Search for graph.nodes by making all unmatched graph.nodes temporarily transparent.
function searchNodes() {
	var term = document.getElementById('searchTerm').value;
	var selected = container.selectAll('.node').filter(function (d, i) {
		return d.name.toLowerCase().search(term.toLowerCase()) == -1;
	});
	selected.style('opacity', '0');
	var link = container.selectAll('.link');
	link.style('stroke-opacity', '0');
	d3.selectAll('.node').transition()
		.duration(5000)
		.style('opacity', '1');
	d3.selectAll('.link').transition().duration(5000).style('stroke-opacity', '0.6');
}

function draw_curve(Ax, Ay, Bx, By, M) {

    // side is either 1 or -1 depending on which side you want the curve to be on.
    // Find midpoint J
    var Jx = Ax + (Bx - Ax) / 2
    var Jy = Ay + (By - Ay) / 2

    // We need a and b to find theta, and we need to know the sign of each to make sure that the orientation is correct.
    var a = Bx - Ax
    var asign = (a < 0 ? -1 : 1)
    var b = By - Ay
    var bsign = (b < 0 ? -1 : 1)
    var theta = Math.atan(b / a)

    // Find the point that's perpendicular to J on side
    var costheta = asign * Math.cos(theta)
    var sintheta = asign * Math.sin(theta)

    // Find c and d
    var c = M * sintheta
    var d = M * costheta

    // Use c and d to find Kx and Ky
    var Kx = Jx - c
    var Ky = Jy + d

    return "M" + Ax + "," + Ay +
           "Q" + Kx + "," + Ky +
           " " + Bx + "," + By
}

function recursivePulse(d) {
  pulse();

  function pulse() {
    d3.select('#n' + d.id.toString())
    .transition().duration(1500).style('opacity', '.5')
    .transition().duration(1500).style('opacity', '1')
    .on('end', pulse);
  }

}
