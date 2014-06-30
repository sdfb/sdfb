var keys = {
	nodes: "0AhtG6Yl2-hiRdHdQM1JrS2JTRklaQ2M1ek41bEs5LVE",
	annot: "0AhtG6Yl2-hiRdGdjLVNKZmJkbkhhNDMzQm5BTzlHX0E"
}

var addNodes;
var addEdges;

document.addEventListener('DOMContentLoaded', function () {
	Tabletop.init({
		key: keys.nodes,
		callback: init
	});
});

function node() {
	this.id = null;
	this.first = null;
	this.last = null;
	this.birth = null;
	this.death = null;
	this.label = null;
	this.name = null;
	this.occupation = null;
	this.edges = [];
}

function group() {
	this.id = null;
	this.name = null;
	this.nodes = null;
}

// Creates a hash of nodes and groups, splits it up based on our database
function init(result) {
	var data = {
		nodes: {},
		groups: {},
		nodes_names: {},
		groups_names: {}
	};
	
	result.nodes.elements.forEach(function (row) {
		var n = new node();
		n.id = row.id;
		n.first = row.first;
		n.last = row.last;
		n.birth = row.birth;
		n.death = row.death; 
		n.occupation = row.occupation;
		n.label = row.first + ' ' + row.last;
		n.name =  n.label + ' (' + row.birth + ')';
		n.edges[0] = row.uncertain.split(', ');
		n.edges[1] = row.unlikely.split(', ');
		n.edges[2] = row.possible.split(', ');
		n.edges[3] = row.likely.split(', ');
		n.edges[4] = row.certain.split(', ');
		data.nodes[n.id] = n;
		data.nodes_names[n.name] = n.id;
	});

	result.groups.elements.forEach(function (row) {
		var g = new group();
		g.id  = row.id;
		g.name = row.name;
		g.nodes = row.nodes.split(', ');
		data.groups[g.id] = g;
		data.groups_names[g.name] = g;
	});

	initGraph(data);
}

// Populates the suggested drop-down menus
// Make the buttons in the search panel functional
function initGraph(data){
	
	populateLists(data);

	//click methods for all the 'find' buttons in the search bar
	$("#findonenode").click(function () {
		if ($("#one").val()) {
			Pace.restart();
			showOneNode(data.nodes_names[$("#one").val()], parseInt($('#confidence1')[0].value), data);
			$('#twogroupsmenu').css('display','none');
		}
		resetInputs();
	});

	$("#findtwonode").click(function () {
		if ($("#two").val() && $("#three").val()) {
			Pace.restart();
			showTwoNodes(data.nodes_names[$("#two").val()], data.nodes_names[$("#three").val()], parseInt($('#confidence2')[0].value), data);			
			$('#twogroupsmenu').css('display','none');
		}
		resetInputs();
	});

	$("#findonegroup").click(function () {
		if ($("#four").val()) {
			Pace.restart();
			showOneGroup($("#four").val(), data);
			$('#twogroupsmenu').css('display','none');
		}
		resetInputs();
	});

	$("#findtwogroup").click(function () {
		if ($("#five").val() && $("#six").val()) {
			Pace.restart();
			$('#group1').html($("#five").val());
			$('#group3').html($("#six").val());
			findInterGroup($("#group1").html(), $("#group3").html(), data);
		}
		resetInputs();
	});

	//click functions for the buttons inside shared groups
	$("#group1").click(function () {
		showOneGroup($("#group1").html(), data);
	});

	$("#group3").click(function () {
		showOneGroup($("#group3").html(), data);
	});

	$("#group2").click(function () {
		findInterGroup($("#group1").html(), $("#group3").html(), data);
	});

	//submission buttons for contributions
	$('#submitnode').click(function(){
		Pace.restart();
		var name = $('#entry_1804360896').val() + ' ' + $('#entry_754797571').val();
		var date = $('#entry_524366257').val();
		$('section').css('display','none');
		$('#addedgeform').css('display','block');
		$('#entry_768090773').val(name + ' (' + date + ')');
		$('#graph').html('');
		$("#results").html('');
		addNodes = [];
		addEdges = [];
		addNodes.push({ "id": 0, "text": name, "size": 14, "cluster": getCluster(date) });
		var options = { width: $("#graph").width(), height: $("#graph").height(), colors: getColors() };
		var graph = new Insights($("#graph")[0], addNodes, [], options).render();
		var link = 'https://docs.google.com/spreadsheets/d/1-faviCW5k2v7DVOHpSQT-grRqNU1lBVkUjJEVfOvSs8/edit#gid=688870062';
		$.prompt("Thank you for your person contribution! You can review your submission by going to <a href='"+link+"' target='_blank'>link</a>");
	});

	$('#submitedge').click(function(){
		Pace.restart();
		var target = data.nodes_names[$('#entry_1321382891').val()];
		var node = data.nodes[target];
		if (!node.id) { window.alert("Incorrect information. Please try again."); return;}
		if (addNodes.length == 0) {return;}
		$('#graph').html('');
		$("#results").html('');
		addNodes.push({ "id": node.id, "text": node.label, "size": 4, "cluster": getCluster(node.birth) });
		addEdges.push([0, node.id]);
		var options = { width: $("#graph").width(), height: $("#graph").height(), colors: getColors() };
		var graph = new Insights($("#graph")[0], addNodes, addEdges, options).render();
		var link = 'https://docs.google.com/spreadsheets/d/1cu7hpYQMWTO8C7F8V34BEbdB2NrUe1xsslWKoai3BWE/edit#gid=51712082';
		$.prompt("Thank you for your annotated relationship contribution! You can review your submission by going to <a href='"+link+"' target='_blank'>link</a>");
	});

	$('#submitgroup').click(function(){
		var link = 'https://docs.google.com/spreadsheet/ccc?key=0AhtG6Yl2-hiRdFFQS2hybWRXRVNkNVJXR2FENnhMM0E&usp=drive_web#gid=0';
		$.prompt("Thank you for your group contribution! You can review your submission by going to <a href='"+link+"' target='_blank'>link</a>");
	});

	$("aside button.icon").click(function(){
		addNodes = [];
		addEdges = [];
		resetInputs();
		var name = $('#node-name').html() + " (" + $('#node-bdate').html() + ")";
        if (this.id == "icon-tag") {
        	$("#entry_1177061505").val(name);
        } else if (this.id == "icon-link") {
        	$("#entry_768090773").val(name);
        }
	});
	showFrancis(data);
	
}

// Displays Francis Bacon's network
function showFrancis(data){
	if ( $("#graph").is(":visible") ){
		showOneNode(968, 3, data);		
	} else {
		setTimeout(function(){ showFrancis(data) }, 1000);
	}
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

// Shows the network of a node
function showOneNode(id, confidence, data) {
	var p = data.nodes[id];
	var keys = {};
	var nodes = [];
	var edges = [];


	var conf = confidence;
	// Makes sure that this is inclusive
	do {
		p.edges[conf].forEach(function (i){
			var f = data.nodes[i];
			if (f) {
				keys[f.id] = { "id": f.id, "text": f.label, "cluster": getCluster(f.birth), "size": 4 };
				if (notInArray(edges, [p.id, f.id])) { edges.push([p.id, f.id]); }
				f.edges[conf].forEach(function (j){
					var s = data.nodes[j];
					if (s) {
						keys[s.id] = { "id": s.id, "text": s.label, "cluster": getCluster(s.birth), "size": 4 };
						if (notInArray(edges, [f.id, s.id])) { edges.push([f.id, s.id]); }
						s.edges[conf].forEach(function (k){
							var t = data.nodes[k];
							if (t && t.id in keys && notInArray(edges, [s.id, t.id])) { edges.push([s.id, t.id]); }
						});
					}
				});
			}
		});
		conf++;
		
	} while (conf < 5); 
	
        	
	keys[p.id] = { "id": p.id, "text": p.label, "cluster": getCluster(p.birth), "size": 14 };
	for (n in keys) { nodes.push(keys[n]); }
	$('#graph').html('');
	$("#results").html("Two degrees of <b>" + p.name +"</b> " + getConfidence(confidence));

	var options = { width: $("#graph").width(), height: $("#graph").height(), colors: getColors() };
	var graph = new Insights($("#graph")[0], nodes, edges, options).render();

	//adding functionality to node and edge clicks
	graph.on("node:click", function(d) {
		var clicked = data.nodes[d.id];
		showNodeInfo(clicked, findGroups(clicked, data));
	});
	graph.on("edge:click", function(d) {
		Pace.restart();
		var id1 = parseInt(d.source.id);
		var id2 = parseInt(d.target.id);
		getAnnotation(id1 < id2 ? id1 : id2, id1 > id2 ? id1 : id2, data);
	});
	showNodeInfo(p, findGroups(p, data));
	$('#zoom button.icon').click(function(e){
		if (this.name == 'in') {
			graph.zoomIn();
		} else if (this.name == 'out') {
			graph.zoomOut();
		}
	});
}

// Checks if a value is in an array
function notInArray(arr, val) {
	var i = arr.length;
	while (i--) {
		if (arr[i][0] == val[0] && arr[i][1] == val[1]) {
			return false;
		}
		if (arr[i][1] == val[0] && arr[i][0] == val[1]) {
			return false;
		}
	}
	return true;
}

// Returns list of groups that a node belongs to
function findGroups(node, data){
	var groups = [];
	for(var key in data.groups){
		if ((data.groups[key].nodes).indexOf(node.id)>-1)
			groups.push(data.groups[key].name);
	}
	var strgroups = groups.join(', ')
	return strgroups;
}

// Displays node information
function showNodeInfo(data, groups){
	accordion("node");
	$("#node-name").text(data.first+ " "+ data.last);
	$("#node-bdate").text(data.birth);
	$("#node-ddate").text(data.death);
	$("#node-significance").text(data.occupation);
	$("#node-group").text(groups);
	var d = new Date();
	$("#node-cite").text( data.first+ " "+ data.last + " Network Visualization. \n Six Degrees of Francis Bacon: Reassembling the Early Modern Social Network. Gen. eds. Daniel Shore and Christopher Warren. "+d.getMonth()+"/"+d.getDate()+"/"+d.getFullYear()+" <http://sixdegreesoffrancisbacon.com/>");
	$("#node-DNBlink").attr("href", "http://www.oxforddnb.com/search/quick/?quicksearch=quicksearch&docPos=1&searchTarget=people&simpleName="+data.first+"-"+data.last+"&imageField.x=0&imageField.y=0&imageField=Go");//"http://www.oxforddnb.com/view/article/"+data.id);
	$("#node-GoogleLink").attr("href", "http://www.google.com/search?q="+data.first+"+"+ data.last);
}


// Display shared network of two nodes
function showTwoNodes(id1, id2, confidence, data) {

	if (id1 === id2) return;
	var keys = {};
	var nodes = [];
	var edges = [];
	var p1 = data.nodes[id1];
	var p2 = data.nodes[id2];
	var nodetable = [];

	p1.edges.forEach(function (list){
		if (list.indexOf(p2.id) > -1) {
			edges.push([p1.id, p2.id]); 
			nodetable.push({"network":p1.label +" → " + p2.label});
			return; 
		}
		
	});
	
	//second and third degree connections
	var conf = confidence; //counter for inclusivity
	do {		
		p1.edges[conf].forEach(function (e){
			if (p2.edges[conf].indexOf(e) > -1) {

				var f = data.nodes[e];
				if(f){
					keys[f.id] = { "id": f.id, "text": f.label, "cluster": getCluster(f.birth), "size": 4 };
					edges.push([p1.id, f.id]);
					edges.push([p2.id, f.id]);

					nodetable.push({"network":p1.label +" → " + f.label +" → " + p2.label});
				}
				
			}
		});
		p1.edges[conf].forEach(function (i){
			var f = data.nodes[i];
			if (f){
				f.edges[conf].forEach(function (j){
					if (p2.edges[conf].indexOf(j) > -1) {
					
						var s = data.nodes[j];
						if (s){
							if (f.id != p2.id && s.id != p1.id) {
								keys[f.id] = { "id": f.id, "text": f.label, "cluster": getCluster(f.birth), "size": 4 };
								keys[s.id] = { "id": s.id, "text": s.label, "cluster": getCluster(s.birth), "size": 4 };
								if (notInArray(edges, [p1.id, f.id])) { edges.push([p1.id, f.id]); }
								if (notInArray(edges, [p2.id, s.id])) { edges.push([p2.id, s.id]); }
								if (notInArray(edges, [f.id,  s.id])) { edges.push([f.id,  s.id]); }
								
								nodetable.push({"network":p1.label +" → " + f.label+ " → "+ s.label +" → "+ p2.label});
							}
						}					
					}
				});

			}
			
		});

		conf++;
		
	} while (conf <5);

	keys[p1.id] = { "id": p1.id, "text": p1.label, "cluster": getCluster(p1.birth), "size": 14 };
	keys[p2.id] = { "id": p2.id, "text": p2.label, "cluster": getCluster(p2.birth), "size": 14 };
	for (n in keys) { nodes.push(keys[n]); }
	$('#graph').html('');
	$("#results").html("Common network between <b>" + p1.label + "</b> and <b>" + p2.label + "</b> " + getConfidence(confidence));
	var options = { width: $("#graph").width(), height: $("#graph").height(), colors: getColors() };
	var graph = new Insights($("#graph")[0], nodes, edges, options).render();

	graph.on("node:click", function(d) {
		var clicked = data.nodes[d.id];
		showNodeInfo(clicked, findGroups(clicked, data));
	});

	$('#zoom button.icon').click(function(e){
		if (this.name == 'in') {
			graph.zoomIn();
		} else {
			graph.zoomOut();
		}
	});

	if($("#check-shared").is(":checked")){
		writeNetworkTable(nodetable, "Common network between <b>" + p1.label + "</b> and <b>" + p2.label + "</b>");
		$('#zoom').css('display','none');
	}
	
}

// Displays the members within a group
function showOneGroup(group, data) {
	var g = data.groups_names[group];
	var results = [];
	g.nodes.forEach(function (n) {	
		results.push(data.nodes[n]);
	});
	if (results.length == 0 || !results[0]) { results = [] }
	writeGroupTable(results, "People who belong to the " + group + " group");
	$("#results").html("People who belong to the <b>" + group + "</b> group");
}

// Displays the intersections between two groups
function findInterGroup(group1, group2, data) {
	var g1 = data.groups_names[group1];
	var g2 = data.groups_names[group2];
	var common = [];
	g1.nodes.forEach(function (node) {
		if (g2.nodes.indexOf(node) >= 0) {
			common.push(data.nodes[node]);
		}
	});
	if (common.length == 0 || !common[0]) { common = [] }
	writeGroupTable(common, "Intersection between " + group1 + " and " + group2);
	$("#results").html("Intersection between <b>" + group1 + "</b> and <b>" + group2 + "</b>");
}

// Creates the table container, used for group and shared group
function writeGroupTable(dataSource, title){
    $('#graph').html('<table cellpadding="0" cellspacing="0" border="0" class="display table table-bordered table-striped" id="data-table-container"></table>');
    $('#data-table-container').dataTable({
		'sPaginationType': 'bootstrap',
		'iDisplayLength': 100,
        'aaData': dataSource,
        'aoColumns': [
            {'mDataProp': 'first', 'sTitle': 'First Name'},
            {'mDataProp': 'last', 'sTitle': 'Last Name'},
            {'mDataProp': 'birth', 'sTitle': 'Birth Date'},
            {'mDataProp': 'death', 'sTitle': 'Death Date'},
            {'mDataProp': 'occupation', 'sTitle': 'Historical Significance'}
        ],
        'oLanguage': {
            'sLengthMenu': '_MENU_ records per page'
        }
    });
    downloadData(dataSource, title);
};

function writeNetworkTable(dataSource, title){
    $('#graph').html('<table cellpadding="0" cellspacing="0" border="0" class="display table table-bordered table-striped" id="data-table-container"></table>');
    $('#data-table-container').dataTable({
		'sPaginationType': 'bootstrap',
		'iDisplayLength': 100,
        'aaData': dataSource,
        'aoColumns': [
            {'mDataProp': 'network', 'sTitle': 'Network'},
        ],
        'oLanguage': {
            'sLengthMenu': '_MENU_ records per page'
        }
    });
};

// Defines two custom functions (asc and desc) for string sorting
jQuery.fn.dataTableExt.oSort['string-case-asc']  = function(x,y) {
	return ((x < y) ? -1 : ((x > y) ?  0 : 0));
};

jQuery.fn.dataTableExt.oSort['string-case-desc'] = function(x,y) {
	return ((x < y) ?  1 : ((x > y) ? -1 : 0));
};

// Takes in the title and data, allows users to download the data
function downloadData(data, title) {
	var result = title + " \n" + 'First Name,Last Name,Birth Date,Death Date,Historical Significance' + "\n";
	data.forEach(function (cell) {
		result += cell["first"] + ',' + cell["last"] + ',' + cell["birth"] + ',' + cell["death"] + ',' + cell["occupation"] + "\n";
	});
	var dwnbtn = $('<a href="data:text/csv;charset=utf-8,' + encodeURIComponent(result) + ' "download="' + title + '.csv"><div id="download"></div></a>');
	$(dwnbtn).appendTo('#graph');
}


// Displays edge information 
function getAnnotation(id1, id2, data) {
	var confidence = findConfidence(id1, id2, data);
	console.log(id1 + ' ' + id2 + ' ' + confidence);
	Tabletop.init({
		key: keys.annot,
		query: 'source= ' + id1 + ' and target= ' + id2,
		wanted: [confidence],
		simpleSheet: true,
		callback: function(result) {
			result.forEach(function (row){
				accordion("edge");
				$("#edge-nodes").html(data.nodes[id1].first +" "+data.nodes[id1].last + " & " + data.nodes[id2].first+" "+data.nodes[id2].last);
				$("#edge-confidence").html(confidence);
				$("#edge-annotation").html(row.annotation);
				$("#edge-contributor").html(row.contributor);
				return true;
			});
		}
	});
	$("#icon-annotate").click(function(){
		resetInputs();
		$("#entry_768090773").val(data.nodes[id1].name);
		$("#entry_1321382891").val(data.nodes[id2].name);
	});
}

// Finds and returns correct confidence on the 0-4 scale
function findConfidence(id1, id2, data) {
	var p1 = data.nodes[id1];
	var p2 = data.nodes[id2];
	var i = -1;
	p1.edges.forEach(function (list, index){
		if (list.indexOf(p2.id) > -1) { i = index; return; }
	});
	if (i == 0) return "very unlikely";
	else if (i == 1) return "unlikely";
	else if (i == 2) return "possible";
	else if (i == 3) return "likely";
	else return "certain";
}

function getConfidence(n) {
	if (n == 0) return "at very unlikely to certain confidence";
	else if (n == 1) return "at unlikely to certain confidence";
	else if (n == 2) return "at possible to certain confidence";
	else if (n == 3) return "at likely to certain confidence";
	else return "at certain confidence";
}

// Populates dropdowns
function populateLists(data){
	$('#one').typeahead({
		local: Object.keys(data.nodes_names).sort()
	});
	$('#two').typeahead({
		local: Object.keys(data.nodes_names).sort()
	});
	$('#three').typeahead({
		local: Object.keys(data.nodes_names).sort()
	});
	$('#entry_768090773').typeahead({
		local: Object.keys(data.nodes_names).sort()
	});
	$('#entry_1321382891').typeahead({
		local: Object.keys(data.nodes_names).sort()
	});
	$('#entry_1177061505').typeahead({
		local: Object.keys(data.nodes_names).sort()
	});
	$('#four').typeahead({
		local: Object.keys(data.groups_names).sort()
	});
	$('#five').typeahead({
		local: Object.keys(data.groups_names).sort()
	});
	$('#six').typeahead({
		local: Object.keys(data.groups_names).sort()
	});
	$('#entry_110233074').typeahead({
		local: Object.keys(data.groups_names).sort()
	});
}


// Resets all input values and forms
function resetInputs(){
	$("#one").val('');
	$("#one").typeahead('setQuery', '');
	$("#two").val('');
	$("#two").typeahead('setQuery', '');
	$("#three").val('');
	$("#three").typeahead('setQuery', '');
	$("#four").val('');
	$("#four").typeahead('setQuery', '');
	$("#five").val('');
	$("#five").typeahead('setQuery', '');
	$("#six").val('');
	$("#six").typeahead('setQuery', '');

	document.getElementById('googleaddnode').reset();
	document.getElementById('googleaddedge').reset();
    document.getElementById('googleaddgroup').reset();
}
