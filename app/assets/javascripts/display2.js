var francisID = 10000473;
//var default_confidence = 75;
//showing all relationships with a confidence of at least 1%
var default_confidence = 40;
var default_sdate = 1400;
var default_edate = 1800;
    // group class
    
function createGroup() {
  this.id = null;
  this.name = null;
  this.nodes = null;
}

// Returns the cluster id based on birth year
function getClusterBirth(year){
  if (parseInt(year) < 1550) {return 0}
  if (parseInt(year) > 1700) {return 1}
  var cluster = Math.round((parseInt(year) - 1550) / 5);
  return (2 + cluster);
}

// Returns hash of colors for nodes based on birthday
function getColorsBirth(){
   return { 0:  "#A6D9CA", 1:  "#F0623E", 2:  "#B99CCA", 3:  "#B8DCF4", 
             4:  "#F9F39C", 5:  "#339998", 6:  "#6566AD", 7:  "#F89939", 
             8:  "#558FCB", 9:  "#04A287", 10: "#B53C84", 11: "#F2805C",
             12: "#79BD90", 13: "#654B9E", 14: "#DD88B8", 15: "#3D58A6",
             16: "#EF4C3A", 17: "#99CC7D", 18: "#4D6AB2", 19: "#A1D7D0",
             20: "#FABC3E", 21: "#EE6096", 22: "#DADC44", 23: "#B177B3",
             24: "#A573B1", 25: "#78CDD6", 26: "#60BD6D", 27: "#3EA7C0",
             28: "#F59485", 29: "#3F6FB6", 30: "#F8EC49", 31: "#1C57A7", }
}

/*
Num_rels Cluster    Color
 0-1		0        orange
 2-3		1        yellow
 4-5		2        aqua blue
 6-7		3        marine blue
 8-9		4        light blue
 10-11		5      hot pink
 12+		6        purple

*/
//returns cluster number based on number of relationships the cluster has
function getClusterRels(node){
	var size = node.size;
	if (size > 11){
		return 6;
	}else{
		return Math.floor(size / 2);
	}

}
//returns colors based on cluster group number
function getColorsRels(){
   return { 0: "#f56046", 1: "#ffbb12", 2: "#73cab5", 3: "#1d7578", 4: "#b6dcf2", 5: "#ff00ff", 6: "#9954e2"}
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
 if (data.odnb_id > 0){
  $("#node-DNBlink").attr("href", "http://www.oxforddnb.com/view/article/"+data.odnb_id);
 }else{
  $("#node-DNBlink").attr("href", "http://www.oxforddnb.com/search/quick/?quicksearch=quicksearch&docPos=1&searchTarget=people&simpleName="+data.first+"+"+data.last);
 }
 $("#node-GoogleLink").attr("href", "http://www.google.com/search?q="+data.first+"+"+ data.last);
 $("#node-discussion").attr("href", "/people/" + data.id);
 $("#node-icon-chain").attr("href", "/relationships/new?person1_id=" + data.id);
 $("#node-icon-annotate").attr("href", "/user_person_contribs/new?person_id=" + data.id);
}

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
  this.rels = 0;
  this.size = 0;

};

//creates a nodekey associative array with node info
function createNodeKey(node) {
  //var nodeKey = {"text": node.first + " " + node.last, "size": 4, "id": node.id,  "cluster": getCluster(node.birth)};
  var nodeKey = {"text": node.first + " " + node.last, "size": 4, "id": node.id,  "cluster": getClusterRels(node)};
  return nodeKey;
}

function peopletoarray(data){
  keys = []
  //console.log(data.nodes[10000099])
  for (var key in data.nodes) {
      keys.push(data.nodes[key].first + " " + data.nodes[key].last + " (" + data.nodes[key].birth + ")");
    }
    return keys
}

function idstoarray(data){
  keys = []
  for (var key in data.nodes) {
      keys.push(data.nodes[key].id);
    }
    return keys
}

function birthtoarray(data){
  keys = []
  for (var key in data.nodes) {
      keys.push(data.nodes[key].birth);
    }
    return keys
}

function twoDegs(id, id2, data, confidence, sdate, edate) {
  var keys = {};
  var nodes = [];
  var edges = [];
  var ids = idstoarray(data);
  var births = birthtoarray(data);

  function createGraph(id, data, confidence, sdate, edate) {
    var p = data.nodes[id];
    if (p.rels.length > 0) { //tests to make sure main person has relationships
      $.each(p.rels, function(index, value) {
        if (value[2] == 0 || value[1] < confidence || sdate > births[ids.indexOf(value[0])] || edate < births[ids.indexOf(value[0])]) {
          // not approved, move on or if confidence is less than 0.75
          console.log("merp");
        }
        else {
          var q = data.nodes[value[0]]; // find person object in data by id
          keys[q.id] = createNodeKey(q); //puts nodekey into keys array
          if (notInArray(edges, [p.id, q.id])) {
            edges.push([p.id, q.id]);
          }
                // if (q && q.rels.length > 0) {
                //   $.each(q.rels, function(index, value) {
                //     if (value[2] != 0 && value[1] >= confidence && sdate < births[ids.indexOf(value[0])] && edate > births[ids.indexOf(value[0])]) { //checks again if relationship id is not zero and confidence is greater than 0.75
                //       console.log("q");
                //       var r = data.nodes[value[0]]; //sets r as data from person id referenced in relationship array
                //       keys[r.id] = createNodeKey(r); //puts nodekey in array for person 2's id
                //       if (notInArray(edges, [q.id, r.id])) {
                //           edges.push([q.id, r.id]);
                //       }
                //       if (r && r.rels.length > 0) { //repeats above code for person 2, finding 2nd deg relationships
                //         $.each(r.rels, function(index, value) {
                //           if (value[2] != 0 && value[1] >= confidence && sdate < births[ids.indexOf(value[0])] && edate > births[ids.indexOf(value[0])]) {
                //             console.log("r");
                //             var s = data.nodes[value[0]];
                //             keys[s.id] = createNodeKey(s);
                //             if (s && (s.id in keys) && notInArray(edges, [r.id, s.id])) {
                //               edges.push([r.id, s.id]);
                //             }
                //           }
                //         });
                //       }
                //     }
                //   });  
                // }
              } 
          });
      //adds main person's id referenced to keys associative array. Keys represent all data in graph
          keys[p.id] = {"text": p.first + " " + p.last, "size": 20, "id": p.id,  "cluster": getClusterRels(p)}; 

    }  
  }
  
  createGraph(id, data, confidence, sdate, edate);
  if (id2 != 0 && id2 != ""){
    createGraph(id2, data, confidence, sdate, edate);
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

$.each(keys, function(index, value) {
  nodes.push(value); //adds each key to nodes array
});

edges.reverse();

  //$("#results").html("Two degrees of <b>" + p.label);

  var w = window.innerWidth;
  var h = window.innerHeight;
  
  var options = { width: w, height: h, collisionAlpha: 10, colors: getColorsRels() };
  var graph = new Insights($("#graph")[0], nodes, edges, options).render();
  graph.focus(id);
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

  graph.tooltip("<div class='btn' >{{text}}</div>");

  $('#zoom button.icon').click(function(e){
    if (this.name == 'in') {
      graph.zoomIn();
      graph.center();
    } else if (this.name == 'out') {
      graph.zoomOut();
      graph.center();
    }
  });
}

$('#zoom button.icon').click(function(e){
    if (this.name == 'in') {
      graph.zoomIn();
    } else {
      graph.zoomOut();
    }
  });

// Returns string stating confidence based on input decimal (0<n1.00)
 function getConfidence(n) {
  if (00 <= n <= 19) return "very unlikely";
  if (20 <= n <= 39) return "unlikely";
  if (40 <= n <= 59) return "possible";
  if (60 <= n <= 79) return "likely";
  if (80 <= n <= 100) return "certain";
 }

// Displays edge information 
function getAnnotation(id1, id2, data) {
  var id1_rel_array = data.nodes[id1].rels;
  var confidence = "";
  var rel_id = "";
  $.each(id1_rel_array, function(index, value) {                    
    if (value[0] == id2){
       confidence = getConfidence(value[1]) + " @ " + value[1] + "%";
       rel_id = value[3];
    }
  });

  accordion("edge");
  $("#edge-nodes").html(data.nodes[id1].first +" "+data.nodes[id1].last + " & " + data.nodes[id2].first+" "+data.nodes[id2].last);
  $("#edge-confidence").html(confidence);
  $("#edge-discussion").attr("href", "/relationships/" + rel_id );
  $("#edge-icon-annotate").attr("href", "/user_rel_contribs/new?relationship_id=" + rel_id );
  //$("#Sir-Mix-a-Lot").html(row.contributor); 
  //$("#edge-annotation").html(row.annotation);
  return true;
    };

  // Populates dropdowns
function populateLists(data){
  var names = peopletoarray(data);
  $('#one').typeahead({
    local: names.sort()
  });
  $('#two').typeahead({
    local: names.sort()
  });
  $('#three').typeahead({
    local: names.sort()
  });
  $('#entry_768090773').typeahead({
    local: names.sort()
  });
  $('#entry_1321382891').typeahead({
    local: names.sort()
  });
  $('#entry_1177061505').typeahead({
    local: names.sort()
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


function getParam ( sname )
{
  var params = location.search.substr(location.search.indexOf("?")+1);
  var sval = "";
  params = params.split("&");
    // split param and value into individual pieces
    for (var i=0; i<params.length; i++)
       {
         temp = params[i].split("=");
         if ( [temp[0]] == sname ) { sval = temp[1]; }
       }
  return sval;
}

function filterGraph(data){
  var ID = getParam("id");
  var ID2 = getParam("id2");
  var conf = getParam("confidence");
  var date = getParam("date");
  var sdate = date.substring(0, 3);
  var edate = date.substring(5, 8);
  if(ID2 == "" || ID2 == "0"){
    ID2 = 0;
  } 
  if(date == ""){
    sdate = default_sdate;
    edate = default_edate;
  }
  if(ID == ""){
    ID = francisID;
  }
  if(conf == ""){
    conf = default_confidence;
  }
  twoDegs(ID, ID2, data, conf, sdate, edate);
}

function initGraph(data, allPeopleNamesData){
  var names = peopletoarray(allPeopleNamesData);
  var ids = idstoarray(allPeopleNamesData);
  //click methods for all the 'find' buttons in the search bar
  $("#findonenode").click(function () {
  	var table = 'no';
    Pace.restart();
    if ($("#one").val()) {
      var index = names.indexOf($("#one").val())
    }
    if ($("#show-table").val() == 1) {
    	table = 'yes'
    }
    var confidence = $("#slider-result-hidden1").val();
    var date = $("#search-date-range1").val().split(" - ");
    // '/?person_id=' + ids[index] + '&confidence=' + confidence + '&date=' + $("search-date-range1").val(); + '&table=' + table;
  	//window.location.href = '/?person_id=' + ids[index] + '&confidence=' + confidence + '&date=' + date + '&table=' + table;
    window.location.href = '/?id=' + ids[index] + '&confidence=' + confidence + '&date=' + date + '&table=' + table;
  });

   $("#findtwonode").click(function () {
      var table = 'no';
      Pace.restart();
      if ($("#two").val()) {
        var index = names.indexOf($("#two").val())
      }
      if ($("#three").val()) {
        var index2 = names.indexOf($("#three").val())
      }
      if ($("#show-table").val() == 1) {
        table = 'yes'
      }
      var confidence = $("#slideredge-result-hidden2").val();
      var date = $("#searchedge-date-range2").val().split(" - ");
      window.location.href = '/?id=' + ids[index] + '&id2=' + ids[index2] + '&confidence=' + confidence + '&date=' + date + '&table=' + table;
    });

  $("#nav-filter").click(function (){
    var ID = getParam("id");
    var confidence = $("#slidenav-result-hidden1").val();
    var date = $("#nav-date-range2").val().split(" - ");
    //var date = $("#searchnav-date-range1").val().split(" - ");
    if ( ID != ""){
      window.location.href = '/?id=' + ID + '&confidence=' + confidence + '&date=' + date;
    }
    if (ID == ""){
      window.location.href = '/?id=' + francisID + '&confidence=' + confidence + '&date=' + date;  
    }

  });

  $("#findonegroup").click(function () {
    if ($("#four").val()) {
      Pace.restart();
      showOneGroup($("#four").val(), data);
      $('#twogroupsmenu').css('display','none');
    }
  });

  $("#findtwogroup").click(function () {
    if ($("#five").val() && $("#six").val()) {
      Pace.restart();
      $('#group1').html($("#five").val());
      $('#group3').html($("#six").val());
      findInterGroup($("#group1").html(), $("#group3").html(), data);
    }
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


  $("aside button.icon").click(function(){
    addNodes = [];
    addEdges = [];
    var name = $('#node-name').html() + " (" + $('#node-bdate').html() + ")";
        if (this.id == "icon-tag") {
          $("#entry_1177061505").val(name);
        } else if (this.id == "icon-link") {
          $("#entry_768090773").val(name);
        }
  });

  
}

function init() {
  //This file only contains the data for the searched person and 1st degree relationships
  var people = gon.people;
  //This file contains all the id, first_name, last_name, ext_birth_year, prefix, suffix, and title for every person in the database
  // var all_people = gon.people_list;

	var data = { nodes: [], edges: [], groups_names: [], nodeKeys: [] };

  //var allPeopleNamesData = { nodes: [], edges: [], groups_names: [], nodeKeys: [] };

  //This function only converts gon to all data for the searched person and 1st degree relationships
  $.each(people, function(index, value) { 
    var n = new node();
    n.id = value.id;
    n.first = value.first_name;
    n.last = value.last_name;
    n.label = n.first + " " + n.last;
    n.birth = value.ext_birth_year;
    n.death = value.ext_death_year;
    n.occupation = value.historical_significance;
    n.rels = value.rel_sum;
    n.size = n.rels.length;
    n.odnb_id = value.odnb_id;
    data.nodes[n.id] = n;
    
  });

  //This function converts gon to name data for all people in the database
  $.each(all_people, function(index, value) { 
    var n = new node();
    n.id = value.id;
    n.first = value.first_name;
    n.last = value.last_name;
    n.prefix = value.prefix;
    n.suffix = value.suffix;
    n.title = value.title
    n.label = n.first + " " + n.last;
    n.birth = value.ext_birth_year;
    n.death = value.ext_death_year;
    allPeopleNamesData.nodes[n.id] = n;   
  });

 populateLists(allPeopleNamesData);
  filterGraph(data);
  initGraph(data, allPeopleNamesData);
  }


$(document).ready(function() {
  console.log(gon.people);
   init();
});

      