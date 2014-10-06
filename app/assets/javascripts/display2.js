

function createNodeKey(node) {
	var nodeKey = {"id": node.id, "text": node.first, "size": getSize(node), "cluster": getCluster(node.birth)};
	return nodeKey;
}

function makeGraph(data) {
	var el = document.getElementById("graph");  // graph element
	var nodes = data.nodeKeys;
	var edges = data.edges;
	var graph = new Insights(el, nodes, edges);
	graph.render();
	
}

function populateData() {
	var people = gon.people;
	var data = { nodes: {}, edges: {}, nodes_names: {}, groups_names: {}, nodeKeys: {}};
	
	$.each(people, function(index, value) {
		var n = new node();
		n.id = value.id;
		n.first = value.first_name;
		n.last = value.last_name;
		n.birth = value.birth_year;
		n.death = value.death_year;
		n.occupation = value.historical_significance;
		n.rels = value.rel_sum; // array
		data.nodes[n.id] = n;
    	n.key = createNodeKey(n);
    	data.nodeKeys[n.id] = n.key;

	});

  	this.createEdges(data);
  	makeGraph(data);
}

function createEdges(data) {
// create array of edges from relationships 
	var people = gon.people;
	$.each(people, function(index, value) {
		var id = value.id;
		var rels = value.rel_sum;
		

		$.each(rels, function() {
			if (rels[2] != 0) {
				data.edges[index] += [id, rels[0]];
			}
			console.log(data.edges[index]);
		});
	});
	
}

// node class
var node = function() {
  this.id = null;
  this.first = null;
  this.last = null;
  this.birth = null;
  this.death = null;
  this.label = null;
  this.name = null;
  this.occupation = null;
  this.edges = [];
  this.key = null;
};

// group class
function group() {
  this.id = null;
  this.name = null;
  this.nodes = null;
}

function getSize(node) {
	var numRels = node.rels.length;
	var nodeSize = numRels * 4;
	return nodeSize;
}

// Returns the color id based on birth year
function getCluster(year){
  if (parseInt(year) < 1550) {return 0}
  if (parseInt(year) > 1700) {return 1}
  var cluster = Math.round((parseInt(year) - 1550) / 5);
  return (2 + cluster);
}

// Returns hash of colors for nodes
function getColors(){
   return { 0:  "#A6D9CA", 1:  "#F0623E", 2:  "#B99CCA", 3:  "#B8DCF4", 
             4:  "#F9F39C", 5:  "#339998", 6:  "#6566AD", 7:  "#F89939", 
             8:  "#558FCB", 9:  "#04A287", 10: "#B53C84", 11: "#F2805C",
             12: "#79BD90", 13: "#654B9E", 14: "#DD88B8", 15: "#3D58A6",
             16: "#EF4C3A", 17: "#99CC7D", 18: "#4D6AB2", 19: "#A1D7D0",
             20: "#FABC3E", 21: "#EE6096", 22: "#DADC44", 23: "#B177B3",
             24: "#A573B1", 25: "#78CDD6", 26: "#60BD6D", 27: "#3EA7C0",
             28: "#F59485", 29: "#3F6FB6", 30: "#F8EC49", 31: "#1C57A7", }
}


$(document).ready(function() {

	populateData();
});
  
