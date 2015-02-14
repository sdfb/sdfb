// Returns string stating confidence based on input decimal (0<n1.00)
function getConfidence(n) {
    if (0 <= n &&  n<= 19) {
        return "very unlikely";}
    else if (20 <= n &&  n<= 39) {
        return "unlikely";}
    else if (40 <= n &&  n<= 59) {
        return "possible";}
    else if (60 <= n && n<= 79) {
        return "likely";}
    else {
        return "certain";}
}

$(document).ready(function() {

    var default_sdate = 1400
    var default_edate = 1800
    var default_certainty = 40
    var default_scertainty = 0
    var default_ecertainty = 100

    //Tooltips
	$("#search-network").tooltip({placement: 	'right', title: 'Connections of one individual'});
	//$("#search-shared-network").tooltip({placement: 	'right', title: 'Mutual connections between two individuals'});
    $("#search-shared-network").tooltip({placement:     'right', title: 'New Feature Coming Soon'});
	$("#search-group").tooltip({placement: 	'right', title: 'Members of one group'});
	//$("#search-shared-group").tooltip({placement: 	'right', title: 'Mutual members of two groups'});
    $("#search-shared-group").tooltip({placement:   'right', title: 'New Feature Coming Soon'});

    $("#contribute-add-person").tooltip({placement:   'right', title: 'Add a new individual to the database'});
    $("#contribute-add-group").tooltip({placement:  'right', title: 'Add a new group to the database'});
    $("#contribute-add-relationship").tooltip({placement:   'right', title: 'Add and annotate a relationship between two individuals'});

    $("#icon-tag").tooltip({placement:  'right', title: 'Tag group'});
    $("#icon-link").tooltip({placement: 'right', title: 'Add a relationship'});
    $("#icon-annotate").tooltip({placement: 'right', title: 'Annotate relationship'});
    $("#icon-info").tooltip({placement: 'left', title: 'Scroll to zoom, double click on node or edge for more information, single click to reset view'});
    $("#icon-color").tooltip({placement: 'left', title: 'Click to view color legend'});

    $("#node-icon-chain").tooltip({placement: 'right', title: 'Add relationship'});
    $("#node-icon-annotate").tooltip({placement: 'right', title: 'Edit person'});
    $("#edge-icon-annotate").tooltip({placement: 'right', title: 'Edit relationship'});
    $("#group-icon-label").tooltip({placement: 'right', title: 'Add person to group'});
    $("#group-icon-annotate").tooltip({placement: 'right', title: 'Edit group'});

    $(".icon-zoomin").tooltip({placement:  'left', title: 'Zoom In'});
    $(".icon-zoomout").tooltip({placement:  'left', title: 'Zoom Out'});
    $(".icon-color").tooltip({placement:  'left', title: 'Colors'});
    $(".icon-info").tooltip({placement:  'left', title: 'Info'});

    $(".slider").tooltip({placement: 'right', title: 'Choose the certainty of relationship'});
	$('#search-network-form').css('display','block');

    $("#search-network-show-table").click(function(){
        $("#search-network-show-table").attr('href', "/people/" + $("#search-network-name-id").val());
    });

    // Color guide
    $("#icon-color").click(function(){
        if( $('#guide').css('display') == 'none' ){
            $("#guide").css('display','block');
        }
        else{
            $("#guide").css('display','none');
        }        
    });
    $("#guide").click(function(){
          $("#guide").css('display','none');
    });

	// Shows search bars when click on side menu
	$('.accordion_content ul li').click(function(e){
        $('.accordion_content ul li').removeClass('clicked');
        $(this).addClass('clicked');
		$('section').css('display','none');	
		var id = '#' + e.target.id + '-form';
		$(id).css('display','block');
	});
	$('.toggle').click(function(e){
		$('.toggle').removeClass('active');
		$(this).addClass('active');
	});
	$('#search-shared-group').click(function(e){
		$('#search-shared-group-form').css('display','block');
	});
    $('section button').click(function(e){
        if (this.name == "node") {
            $('#zoom').css('display','block');
        } else if (this.name == "group") {
            $('#zoom').css('display','none');
        }
    });
    $("aside button.icon").click(function(e){
        $('.accordion_content ul li').removeClass('clicked');
        $('section').css('display','none');
        $('#add' + this.name).addClass('clicked');
        $('#add'+ this.name + 'form').css('display','block');
        $('#accordion h3').removeClass('on');
        $('#accordion div').slideUp();
        $('#contribute').prev().addClass('on');
        $('#contribute').slideDown();
    });

 //  Sliding animation
	$("#search-network-slider-confidence").slider({
        animate: true,
        range: "min",
        value: default_certainty,
        min: default_scertainty,
        max: default_ecertainty,
        step: 1,
        // Gets a live reading of the value and prints it on the page
        slide: function( event, ui ) {
        	var result = getConfidence(ui.value);
            $("#search-network-slider-confidence-result").html( result + " relationships @ " + ui.value + "%");
            $("#search-network-slider-confidence-result-hidden").val(ui.value);
        }
    });

    $("#search-network-slider-date").slider({
        animate: true,
        range: "min",
        value: 3,
        min: default_sdate,
        max: default_edate,
        step: 1,
        values: [ default_sdate, default_edate ],
        slide: function( event, ui ) {
            $("#search-network-slider-date-result" ).html("Date Range: " + ui.values[ 0 ] + " - " + ui.values[ 1 ] );
            $("#search-network-slider-date-result-hidden").val(ui.values[ 0 ] + " - " + ui.values[ 1 ]);
        }
    });

    $("#search-shared-network-slider-confidence").slider({
        animate: true,
        range: "min",
        value: default_certainty,
        min: default_scertainty,
        max: default_ecertainty,
        step: 1,
        // Gets a live reading of the value and prints it on the page
        slide: function( event, ui ) {
            var result = getConfidence(ui.value);
            $("#search-shared-network-slider-confidence-result").html( result + " relationships @ " + ui.value + "%");
            $("#search-shared-network-slider-confidence-result-hidden").val(ui.value);
        }
    });
	
    $("#search-shared-network-slider-date").slider({
        animate: true,
        range: "min",
        value: 3,
        min: default_sdate,
        max: default_edate,
        step: 1,
        values: [ default_sdate, default_edate ],
        slide: function( event, ui ) {
            $("#search-shared-network-slider-date-result").html("Date Range: " +  ui.values[ 0 ] + " - " + ui.values[ 1 ] );
            $("#search-shared-network-slider-date-result-hidden").val(ui.values[ 0 ] + " - " + ui.values[ 1 ]);
        }
    });

    $("#nav-slider-confidence").slider({
        animate: true,
        range: "min",
        value: 3,
        min: default_scertainty,
        max: default_ecertainty,
        step: 1,
        // Gets a live reading of the value and prints it on the page
        slide: function( event, ui ) {
            var result = getConfidence(ui.value);             
            $("#nav-slider-confidence-result").html( result + " relationships @ " + ui.value + "%");
            $("#nav-slider-confidence-result-hidden").val(ui.value);
        }
    });

    //  Sliding animation
    $("#nav-slider-date").slider({
        animate: true,
        range: "min",
        value: 3,
        min: default_sdate,
        max: default_edate,
        step: 1,
        values: [ default_sdate, default_edate],
        slide: function( event, ui ) {
            $( "#nav-slider-date-result" ).val( ui.values[ 0 ] + " - " + ui.values[ 1 ] );
        }
    });

    $("#nav-anchor").click(function() {
        $("#nav-slider").toggle( "fast", function() {
        });
    });


});