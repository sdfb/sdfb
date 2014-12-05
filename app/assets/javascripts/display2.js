var francisID = 199;
    // group class
function createGroup() {
  this.id = null;
  this.name = null;
  this.nodes = null;
}

function createNodeKey(node) {
  var nodeKey = {"text": node.first + " " + node.last, "size": 4, "id": node.id,  "cluster": getCluster(node.birth)};
  return nodeKey;
}





function getSize(node) {
	// base off number of connections the node has 
  var numRels = node.size;
  var size = node.size; // default size

  if (numRels == 0) {
    size = 10;
  }
  else {
    size = numRels * 20;

    if (size > 200) {
      size = 200; // max cap on size
    }
  }

  return size;
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
 $("#node-DNBlink").attr("href", "http://www.oxforddnb.com/search/quick/?quicksearch=quicksearch&docPos=1&searchTarget=people&simpleName="+data.first+"-"+data.last+"&imageField.x=0&imageField.y=0&imageField=Go");//"http://www.oxforddnb.com/view/article/"+data.id);
 $("#node-GoogleLink").attr("href", "http://www.google.com/search?q="+data.first+"+"+ data.last);
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

function twoDegs(id, data) {

  // francis ID = 968;
  
  var p = data.nodes[id];
  var keys = {};
  var nodes = [];
  var edges = [];

  if (p.rels.length > 0) {
    $.each(p.rels, function(index, value) {
      
      if (value[2] == 0 && value[1] > 0.9) {
        // not approved, move on
      }
      else {
        var q = data.nodes[value[0]]; // find person object in data by id
        keys[q.id] = createNodeKey(q);
        if (notInArray(edges, [p.id, q.id])) {
          edges.push([p.id, q.id]);
        }
              if (q && q.rels.length > 0) {
                $.each(q.rels, function(index, value) {
                  if (value[2] != 0) {
                    var r = data.nodes[value[0]];
                    keys[r.id] = createNodeKey(r);

                    if (notInArray(edges, [q.id, r.id])) {
                        edges.push([q.id, r.id]);
                    }

                    if (r && r.rels.length > 0) {
                      $.each(r.rels, function(index, value) {
                        if (value[2] != 0 && value[1] > 0.9) {
                          var s = data.nodes[value[0]];
                          keys[s.id] = createNodeKey(s);

                          if (s && (s.id in keys) && notInArray(edges, [r.id, s.id])) {
                            edges.push([r.id, s.id]);
                          }
                        }
                      });
                    }
                  }
                });  
              }
            } 
        });

        keys[p.id] = {"text": p.first + " " + p.last, "size": 14, "id": p.id,  "cluster": getCluster(p.birth)};
  }  

$.each(keys, function(index, value) {
  nodes.push(value);
});

  $('#graph').html('');
  $("#results").html("Two degrees of <b>" + p.label);
  
  var options = { width: $("#graph").width(), height: $("#graph").height(), colors: getColors() };
  var graph = new Insights($("#graph")[0], nodes, edges, options).render();
  graph.center();
  graph.focus(francisID);


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
  $('#zoom button.icon').click(function(e){
    if (this.name == 'in') {
      graph.zoomIn();
    } else if (this.name == 'out') {
      graph.zoomOut();
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

    //Tooltips
  $("#onenode").tooltip({placement:   'right', title: 'Connections of one individual'});
  $("#twonode").tooltip({placement:   'right', title: 'Mutual connections between two individuals'});
  $("#onegroup").tooltip({placement:  'right', title: 'Members of one group'});
  $("#twogroup").tooltip({placement:  'right', title: 'Mutual members of two groups'});

    $("#addnode").tooltip({placement:   'right', title: 'Add a new individual to the database'});
    $("#addgroup").tooltip({placement:  'right', title: 'Add a member to an existing or new group'});
    $("#addedge").tooltip({placement:   'right', title: 'Add and annotate a relationship between two individuals'});

    $("#icon-tag").tooltip({placement:  'right', title: 'Tag group'});
    $("#icon-link").tooltip({placement: 'right', title: 'Add a relationship'});
    $("#icon-annotate").tooltip({placement: 'right', title: 'Annotate relationship'});
    $("#icon-info").tooltip({placement: 'left', title: 'Scroll to zoom, double click on node or edge for more information, single click to reset view'});
    $("#icon-color").tooltip({placement: 'left', title: 'Click to view color legend'});

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

 // Takes in the title and data, allows users to download the data
function downloadData(data, title) {
  var result = title + " \n" + 'First Name,Last Name,Birth Date,Death Date,Historical Significance' + "\n";
  data.forEach(function (cell) {
    result += cell["first"] + ',' + cell["last"] + ',' + cell["birth"] + ',' + cell["death"] + ',' + cell["occupation"] + "\n";
  });
  var dwnbtn = $('<a href="data:text/csv;charset=utf-8,' + encodeURIComponent(result) + ' "download="' + title + '.csv"><div id="download"></div></a>');
  $(dwnbtn).appendTo('#graph');
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


function init() {
  var people = gon.people;

	var data = { nodes: [], edges: [], nodes_names: [], groups_names: [], nodeKeys: []};
  
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
    data.nodes[n.id] = n;
    
  });


  twoDegs(francisID, data);
  populateLists(data);

}



$(document).ready(function() {
    init();
});

      