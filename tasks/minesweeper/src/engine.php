<?php
include("const.php");
include("image_lib.php");

//========================================================================
header("Content-Type: text/xml");
echo "<?xml version='1.0' standalone='yes'?>";

function exit_engine($status, $msg, $img = false, $face = false, $flags = false, $tm = "0") {
	function tag($name, $value) { return "<$name>$value</$name>"; }
	exit(tag("root",
			tag("wins", $_SESSION["wins"]).tag("status", $status).tag("msg", $msg).
			tag("img", $img).tag("face", $face).tag("flags", $flags).tag("time", $tm)
	));
}

function exit_gameover($st, $msg = "") {
	$_SESSION["game_status"] = $st;
	save_to_img($_SESSION["field"], $_SESSION["game"], session_id(), true);

	$_SESSION["wins"] = $st == 1 ? $_SESSION["wins"] + 1 : 0;
	$status = $st == 1 ? "gamover_win" : "gamover_lose";
	$img = get_img();
	$face = get_face($st);
	$flags = get_num($_SESSION["flags"]);

	if ($_SESSION["wins"] >= 3) {
		$status = "flag";
		$msg = "RUCTF_7a81cfd2c9376c6f2f853e0230b95e04";
	}

	exit_engine($status, $msg, $img, $face, $flags);
}

//========================================================================

session_start();

if (empty($_SESSION)) {
	exit_engine("error", "go to start page before");
}
//========================================================================

if ($_SESSION["game_status"] != 0) {
	exit_engine("error", "gameover, bro");
}

//========================================================================

if ($_SESSION["time"] > 0) {
	$tm = TIME_LIMIT - (time() - $_SESSION["time"]);

	// lose because time
	if ($tm <= 0) {
		exit_gameover(2, "time limit, bro");
	}

	if (isset($_GET["timer"])) {
		exit_engine(false, false, false, false, false, $tm);
	}
}

//========================================================================

// check input correct
if (!isset($_POST["i"]) || !isset($_POST["j"]) || !isset($_POST["btn"])) {
	exit_engine("error", "_achtung_ incorrect post");
}
$click_i = (int) $_POST["i"];
$click_j = (int) $_POST["j"];
$btn = (int) $_POST["btn"];

if ($click_i < 0 || $click_i >= FIELD_H ||
	$click_j < 0 || $click_j >= FIELD_W ||
	$btn < 1 || $btn > 2) {
	exit_engine("error", "_achtung_ incorrect values");//, "msg=".$_POST['i'].$_POST['j'].$_POST['btn']);
}

//========================================================================

function try_open_cells_recursive($i, $j) {
	$queue = array($i, $j);
	while (count($queue) > 0) {
		// pop in reverse order
		$j = array_pop($queue);
		$i = array_pop($queue);

		if ($_SESSION["field"][$i][$j] < 9) {
			if ($_SESSION["game"][$i][$j] <= 0) {
				$_SESSION["game"][$i][$j] = 1;
				$_SESSION["num_opened"]++;
			}
		}
		if ($_SESSION["field"][$i][$j] > 0) {
			continue;
		}
		for ($sh_i = $i-1; $sh_i < $i+2; ++$sh_i) {
			for ($sh_j = $j-1; $sh_j < $j+2; ++$sh_j) {
				if ($sh_i >= 0 && $sh_i < FIELD_H && $sh_j >= 0 &&
					$sh_j < FIELD_W && $_SESSION["game"][$sh_i][$sh_j] <= 0) {
					array_push($queue, $sh_i, $sh_j);
				}
			}
		}
	}
}

//========================================================================

$field_val = $_SESSION["field"][$click_i][$click_j];
$game_val = $_SESSION["game"][$click_i][$click_j];

//========================================================================

// click on closed or on tip
if ($game_val <= 0) {
	// left click
	if ($btn == 1) {
		// start timer
		if ($_SESSION["time"] < 0) {
			$_SESSION["time"] = time();
		}
		// bomb, gamover, lose
		if ($field_val == 9) {
			$_SESSION["game"][$click_i][$click_j] = 3;
			exit_gameover(2, "bomb, bro");
		}
		else {
			try_open_cells_recursive($click_i, $click_j);
			// check win
			if ($_SESSION["num_opened"] == FIELD_H*FIELD_W - MINES) {
				exit_gameover(1, "gratz");
			}
		}
		save_to_img($_SESSION["field"], $_SESSION["game"], session_id());
	}
	// right click
	else {
		if ($_SESSION["flags"] > 0) {
			$_SESSION["flags"]--;
			$_SESSION["game"][$click_i][$click_j] = 2;
			save_to_img($_SESSION["field"], $_SESSION["game"], session_id());
		}
	}
}

//========================================================================

// already opened
else if ($game_val == 1) {
	exit_engine("error", "nothing to do");
}

//========================================================================

// flag
else if ($game_val == 2) {
	// left click
	if ($btn == 1) {
		exit_engine("error", "nothing to do");
	}
	// right click
	else {
		$_SESSION["flags"]++;
		$_SESSION["game"][$click_i][$click_j] = 0;
		save_to_img($_SESSION["field"], $_SESSION["game"], session_id());
	}
}

//========================================================================

$status = "ok";
$msg = "ok";
$img = get_img();
$face = get_face($_SESSION["game_status"]);
$flags = get_num($_SESSION["flags"]);
exit_engine($status, $msg, $img, $face, $flags);
?>
