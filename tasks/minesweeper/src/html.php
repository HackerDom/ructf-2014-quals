<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
    <title>Minesweeper</title>

	<script class="jquery" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.0/jquery.min.js">
	</script>
	<!--[if IE]>
  		<script src="http://html5shiv.googlecode.com/svn/trunk/html5.js"></script>
	<![endif]-->
	<style>
		body {
	    	background-image: url(images/bg.png);
	    	background-repeat: no-repeat;
	    }
    </style>

</head>
<body>
	<?php
	function rndsrc($url) {
		return "\"$url?".time().rand(0, 1000)."\"";
	}
	?>

	<script type="text/javascript" src=<?php echo rndsrc("jsengine.js"); ?>></script>

	<div style="position:absolute; left: 101px; top: 156px">
		<img src=<?php echo rndsrc(get_img()); ?> id="click_box" />
	</div>
	<div style="position:absolute; left: 106px; top: 117px">
		<img src=<?php echo rndsrc(get_num(MINES)); ?> id="flags" />
	</div>
	<div style="position:absolute; left: 329px; top: 117px">
		<img src=<?php echo rndsrc(get_face($_SESSION['game_status'])); ?> id="face" />
	</div>
	<div style="position:absolute; left: 535px; top: 117px">
		<img src=<?php echo rndsrc(get_num(TIME_LIMIT)); ?> id="time" />
	</div>
	<!--
	images/bitmaps.png
	-->
</body>
</html>