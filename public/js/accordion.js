$(document).ready(function(){
	$("#accordion h3").click(function(){
		$('#accordion h3').removeClass('on');
		$(this).addClass('on');
		$("#accordion div").slideUp();
		if(!$(this).next().is(":visible")) {
			$(this).next().slideDown();
		}
	})
})

// When a user clicks on a node or edge.
function accordion(item) {
	$(".accordion_content").removeClass('active');
	$(".accordion_content").slideUp();
	$("#accordion h3").removeClass('on');
	$("#" + item + "info").prev().addClass('on');	
	$("#" + item + "info").addClass("active");
	$("#" + item + "info").slideDown();
}