function rndsrc(url) {
	var	d = new Date;
	return url + '?' + d.getTime();
}

function update_screen(data) {
	var root = data.getElementsByTagName('root')[0];
	var status = root.getElementsByTagName('status')[0].childNodes[0].nodeValue;
	var msg = root.getElementsByTagName('msg')[0].childNodes[0].nodeValue;
	if (status != "error") {
		var img = root.getElementsByTagName('img')[0].childNodes[0].nodeValue;
		var face = root.getElementsByTagName('face')[0].childNodes[0].nodeValue;
		var flags = root.getElementsByTagName('flags')[0].childNodes[0].nodeValue;

		$("#click_box").attr("src", rndsrc(img));
		$("#face").attr("src", rndsrc(face));
		$("#flags").attr("src", rndsrc(flags));
	}
	//$('#position').text(status + "\n" + msg + "\n" + img + "\n" + face + "\n" + flags);
}

function click_handler(button, x, y) {
	function get_ij(x, y) {
		var i = Math.floor(y / 16);
		var j = Math.floor(x / 16);

		return {'i': i, 'j': j};
	}

	data = get_ij(x, y);
	data['btn'] = button;
	$.ajax({
		type: 'post',
		url:  'engine.php',
		data: data,
		dataType: 'xml',
		success: update_screen/*,
		error: function (data) {
			$('#position').text("fail");
		}*/
	});
}

var start_timer = (function() {
	// static_variable
	var started = 0;
	return function() {
		if (started) return;
		started = 1;
		var intervalID = setInterval(function() {
			$.get('engine.php?timer', function(data) {
				var root = data.getElementsByTagName('root')[0];
				var time = root.getElementsByTagName('time')[0].childNodes[0].nodeValue;

				$("#time").attr("src", rndsrc('numbers/' + time + '.png'));
				if (time == 0) {
					clearInterval(intervalID);
					update_screen(data);
				}
			}, 'xml');
		}, 1000);
	};
})();

$(document).ready(function() {
	$('#click_box').click(function(e) {
		var offset = $(this).offset();
		var x = (e.clientX - offset.left);
		var y = (e.clientY - offset.top);

		click_handler(1, x, y);
		start_timer();
	});

	$('#click_box').bind('contextmenu', function(e) {
	    if(e.button === 2) {
		    e.preventDefault();

			var offset = $(this).offset();
			var x = (e.clientX - offset.left);
			var y = (e.clientY - offset.top);

			click_handler(2, x, y);
		}
	});

	$('#face').click(function(e) {
		document.location = ".";
	});
});