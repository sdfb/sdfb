 $(document).ready(function(){
    $('#kickback').hide();
 	if(document.cookie == 'skiplanding=yes'){
 		$('#landing').fadeOut();
 		$('#everything').show();
 	}else{
 		date = new Date();
        date.setTime(date.getTime()+(24*60*60*1000));
        expires = "; expires="+date.toGMTString();
 		document.cookie="skiplanding=yes; expires="+expires;
 	};

 	$('#skipIntro').mouseover(function(){
		
 		document.body.style.cursor = 'pointer';
 	}).mouseout(function(){
 		document.body.style.cursor = 'auto';
 	});

 	$('#skipIntro').click(function(){
 		$('#landing').fadeOut();
 		$('#everything').fadeIn();
 	});
 	var i = 0;
 	$('#arrow').click(function(){
 		$('#landing-open').slideUp();
 		$('#landing-def').fadeIn();
 		$('#arrows').fadeIn();
 		i++;
 	});
 	$('#arrow-down').click(function(){
 		if (i == 0){ //starting page
 			$('#landing-open').slideUp();
 			$('#landing-def').fadeIn();
 		} else if (i==1){ //definition
 			$('#landing-def').slideUp();
 			$('#landing-what').fadeIn();
 		} else if (i==2){ //3 circles
 			$('#landing-what').slideUp();
 			$('#landing-features').fadeIn();
 		} else if (i==3){ //search
 			$('#landing-features').slideUp();
 			$('#landing-sidebar').fadeIn();
 		} else if (i==4){ //sidebar
 			$('#landing').fadeOut();
 			$('#everything').fadeIn();
 		}
 		if (i >= 0 && i < 4){ i++ };
 	});

 	$('#arrow-up').click(function(){
 		if (i == 1){ //starting page
 			$('#landing-def').fadeOut();
 			$('#landing-open').slideDown();
 		} else if (i==2){
 			$('#landing-what').fadeOut();
 			$('#landing-def').slideDown();

 		} else if (i==3){
 			$('#landing-features').fadeOut();
 			$('#landing-what').slideDown();
 		} else if (i==4){
 			$('#landing-sidebar').fadeOut();
 			$('#landing-features').slideDown();
 		}
 		if (i > 0 && i <= 4){ i-- };
 	});

 	$('#arrow').mouseover(function(){
 		document.body.style.cursor = 'pointer';
 	}).mouseout(function(){
 		document.body.style.cursor = 'auto';
 	});
 	$('#arrow-down').mouseover(function(){
 		document.body.style.cursor = 'pointer';
 	}).mouseout(function(){
 		document.body.style.cursor = 'auto';
 	});
 	$('#arrow-up').mouseover(function(){
 		document.body.style.cursor = 'pointer';
 	}).mouseout(function(){
 		document.body.style.cursor = 'auto';
 	});
	

 });