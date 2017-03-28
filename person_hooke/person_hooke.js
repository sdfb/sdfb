
var svg = d3.select("svg"),
    width = +svg.attr("width"),
    height = +svg.attr("height");

var graph,
    sourceId;

var threshold = 60;
var complexity = 2.5;

svg.append('rect')
    .attr('width', '100%')
    .attr('height', '100%')
    .attr('fill', '#FFFFFF')
    .on('click', function() {
      if (toggle == 1) {
        // Restore nodes and links to normal opacity. (see toggleClick() below)
        d3.selectAll('.link').style('stroke', '#000');
        d3.select('[pulse="true"]').transition().duration(200).style('opacity', 1);
        d3.selectAll('.node').style('fill', function(d) { return color(d.distance); }).attr('pulse', false);
        d3.selectAll('span').remove();
        toggle = 0;
      }
    });

// Call zoom for svg container.
svg.call(d3.zoom().on('zoom', zoomed));//.on("dblclick.zoom", null);

var container = svg.append('g');

// Create form for search (see function below).
var search = d3.select("div#tools").append('form').attr('onsubmit', 'return false;');

var color = d3.scaleOrdinal()
    .domain([0,1,2])
    .range(['#1253a0','#1253a0','#87a9cf']);

var degreeSize = d3.scaleLog()
    .domain([1,500])
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

  graph = json.data.attributes;
  currentNodes = graph.nodes;
  currentLinks = graph.links;
  sourceId = json.included.id;

  simulation = d3.forceSimulation(graph.nodes)
      // .velocityDecay(.5)
      .force("link", d3.forceLink(graph.links).id(function(d) { return d.id; }))
      .force("charge", d3.forceManyBody().strength([-300]))//.distanceMax([500]))
      .force("center", d3.forceCenter(width / 2, height / 2))
      .force("collide", d3.forceCollide().radius( function (d) { return degreeSize(d.degree); }))
      .force("x", d3.forceX())
      .force("y", d3.forceY())
      .stop();

  for (var i = 0, n = Math.ceil(Math.log(simulation.alphaMin()) / Math.log(1 - simulation.alphaDecay())); i < n; ++i) {
    simulation.tick();
  }

  update(threshold, complexity);

});

	// A slider that removes nodes and edges below the input threshold.
var confidenceSlider = d3.select('div#tools').append('div').text('Confidence Estimate (1- and 2-degree only): ');

var confidenceSliderLabel = confidenceSlider.append('label')
	.attr('for', 'threshold')
  .attr('id', 'confidenceLabel')
	.text('60');
var confidenceSliderMain = confidenceSlider.append('input')
	.attr('type', 'range')
	.attr('min', 0)
	.attr('max', 100)
	.attr('value', 60)
	.attr('id', 'threshold')
	.style('width', '50%')
	.style('display', 'block')
	.on('input', function () {
		threshold = this.value;

		d3.select('#confidenceLabel').text(threshold);

    update(threshold, complexity);

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

    complexity = this.value;

    d3.select("#complexityLabel").text("Network Complexity: "+complexity+" ");

    update(threshold, complexity);

});

function parseComplexity(thresholdLinks, complexity) {

  var oneDegreeNodes = [];
  thresholdLinks.forEach(function(l){
    if (l.source.id == sourceId || l.target.id == sourceId ) { oneDegreeNodes.push(l.source); oneDegreeNodes.push(l.target);};
  });

  oneDegreeNodes = Array.from(new Set(oneDegreeNodes));

  var twoDegreeNodes = [];
  thresholdLinks.forEach(function(l) {
    if (oneDegreeNodes.indexOf(l.source) != -1 && oneDegreeNodes.indexOf(l.target) == -1) { twoDegreeNodes.push(l.target); }
    else if (oneDegreeNodes.indexOf(l.target) != -1 && oneDegreeNodes.indexOf(l.source) == -1) {twoDegreeNodes.push(l.source); };
  });

  twoDegreeNodes = Array.from(new Set(twoDegreeNodes));

  var allNodes = oneDegreeNodes.concat(twoDegreeNodes);

  allNodes.forEach(function(d) {
    if (d.id == sourceId) { d.distance = 0; }
    else if (oneDegreeNodes.indexOf(d) != -1) { d.distance = 1; }
    else { d.distance = 2; }
  });

    if (complexity == 1) {
      var newLinks = thresholdLinks.filter(function(l) { if (l.source.id == sourceId || l.target.id == sourceId) { return l; }})
      return [oneDegreeNodes, newLinks];
    }

    if (complexity == 1.5) {

      var newLinks = thresholdLinks.filter(function(l) {if (oneDegreeNodes.indexOf(l.source) != -1 && oneDegreeNodes.indexOf(l.target) != -1) {return l;}});
      return [oneDegreeNodes, newLinks];
    }

    if (complexity == 1.75) {
      var newLinks = thresholdLinks.filter(function(l) {if (oneDegreeNodes.indexOf(l.source) != -1 || oneDegreeNodes.indexOf(l.target) != -1) {return l;}});
      var newNodes = [];
      twoDegreeNodes.forEach(function(d){
        var count = 0;
        newLinks.forEach(function(l){
          if (l.source == d && oneDegreeNodes.indexOf(l.target) != -1) { count += 1; }
        });
        if (count >= 2) { newNodes.push(d); }
      });

      // newNodes = Array.from(new Set(newNodes));

      newNodes = oneDegreeNodes.concat(newNodes);
      newLinks = thresholdLinks.filter(function(l) {if (newNodes.indexOf(l.source) != -1 && newNodes.indexOf(l.target) != -1) {return l;}});
      return [newNodes, newLinks];
    }

    if (complexity == 2) {
      newLinks = thresholdLinks.filter(function(l) { if (oneDegreeNodes.indexOf(l.source) != -1 || oneDegreeNodes.indexOf(l.source) != -1) {return l;} });
      return [allNodes, newLinks];
    }

    if (complexity == 2.5) {

      var newLinks = thresholdLinks.filter(function(l) {if (allNodes.indexOf(l.source) != -1 && allNodes.indexOf(l.target) != -1) {return l;}});

      return [allNodes, newLinks];
    }
}

function update(threshold, complexity) {

  d3.select('.source-node').remove(); //Get rid of old source node highlight.

  // Find the links and nodes that are at or above the threshold.
  var thresholdLinks = graph.links.filter(function(d) { if (d.weight >= threshold) {return d; }; });

  var newData = parseComplexity(thresholdLinks, complexity);
  var newNodes = newData[0];
  var newLinks = newData[1];

  // Data join with only those new links and corresponding nodes.
  link = link.data(newLinks, function(d) {return d.source.id + ', ' + d.target.id;});
  link.exit().remove();
  var linkEnter = link.enter().append('path')
    .attr('class', 'link');
      link = linkEnter.merge(link)
      .attr("d", linkArc)
      .attr('stroke-opacity', function(l) { if (l.altered == true) { return 1;} else {return .35;} });

  // When adding and removing nodes, reassert attributes and behaviors.
  node = node.data(newNodes, function(d) {return d.id;})
  .attr("cx", function(d) { return d.x; })
  .attr("cy", function(d) { return d.y; });
  node.exit().remove();
  var nodeEnter = node.enter().append('circle');


  node = nodeEnter.merge(node)
    .attr('r', function(d) { return degreeSize(d.degree);})
    .attr("fill", function(d) { return color(d.distance); })
    .attr('class', 'node')
    .attr('id', function(d) { return "n" + d.id.toString(); })
    .attr("cx", function(d) { return d.x; })
    .attr("cy", function(d) { return d.y; })
    .attr("pulse", false)
    .attr("is_source", function(d) {if (d.id == sourceId) {return 'true';} })
    // On click, toggle ego networks for the selected node. (See function above.)
    .on('click', function(d) { toggleClick(d, newLinks); });

    node.append("title")
        .text(function(d) { return d.name; });

  d3.select('.nodes').insert('circle', '[is_source="true"]')
    .attr('r', degreeSize(d3.select('[is_source="true"]').data()[0].degree) + 10)
    .attr('fill', color(d3.select('[is_source="true"]').data()[0].distance))
    .attr('class', 'source-node')
    .attr("cx", d3.select('[is_source="true"]').data()[0].x)
    .attr("cy", d3.select('[is_source="true"]').data()[0].y);
}

// A function to handle click toggling based on neighboring graph.nodes.
function toggleClick(d, newLinks) {


  // Make object of all neighboring nodes.
   connectedNodes = {};
   connectedNodes[d.id] = true;
   newLinks.forEach(function(l) {
     if (l.source.id == d.id) { connectedNodes[l.target.id] = true; }
     else if (l.target.id == d.id) { connectedNodes[l.source.id] = true; };
   });

      if (toggle == 0) {
        recursivePulse(d);
        // Ternary operator restyles links and nodes if they are adjacent.
        d3.selectAll('.link').style('stroke', function (l) {
          return l.target == d || l.source == d ? 1 : '#D3D3D3';
        });
        d3.selectAll('.node').style('fill', function (n) {
          if (n.id in connectedNodes) { return color(n.distance); }
          else { return '#D3D3D3'; };
        });

    // Show information when node is clicked
    d3.select('div#tools').append('span').text("Name: " + d.name + "  |  Historical Significance: " + d.historical_significance + "  |  Lived: " + d.birth_year + "-" + d.death_year);
        toggle = 1;
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

function linkArc(d) {
  var dx = d.target.x - d.source.x,
      dy = d.target.y - d.source.y,
      dr = Math.sqrt(dx * dx + dy * dy);
  return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
}

function recursivePulse(d) {
  pulse();

  function pulse() {
    d3.select('#n' + d.id.toString())
    .attr('pulse', true)
    .transition().duration(1500).style('opacity', .5)
    .transition().duration(1500).style('opacity', 1)
    .on('end', pulse);
  }

}
