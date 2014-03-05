<?php
include("const.php");
include("image_lib.php");
//=======================================================================================
// init field
//=======================================================================================
function cnt_mines($field, $i, $j) {
	$ret = 0;
	for ($sh_i = $i-1; $sh_i < $i+2; ++$sh_i) {
		for ($sh_j = $j-1; $sh_j < $j+2; ++$sh_j) {
			if ($sh_i < 0 || $sh_i >= FIELD_H || $sh_j < 0 || $sh_j >= FIELD_W) {
				continue;
			}
			if ($field[$sh_i][$sh_j] == 9) ++$ret;
		}
	}
	return $ret;
}
function init_field(&$field, &$game) {
	$field = array();
	$game = array();
	// init values
	for ($i = 0; $i < FIELD_H; ++$i) {
		$field[] = array();
		$game[] = array();
		for ($j = 0; $j < FIELD_W; ++$j) {
			$field[$i][$j] = 0;
			// 0 - closed, 1 - open, 2 - flag, 3 - boom (fail cell in gameover)
			$game[$i][$j] = 0;
		}
	}

	// bombs
	for ($i = 0; $i < MINES; ++$i) {
		do {
	    	$r_i = rand(0, FIELD_H-1);
	    	$r_j = rand(0, FIELD_W-1);
	 	} while ($field[$r_i][$r_j] == 9);
		$field[$r_i][$r_j] = 9;
	}

	// numerals
	$tips = array(false, false, false, false);
	for ($i = 0; $i < FIELD_H; ++$i) {
		for ($j = 0; $j < FIELD_W; ++$j) {
			if ($field[$i][$j] != 9) {
				$field[$i][$j] = cnt_mines($field, $i, $j);
				// hardcore
				// formula: [0][0] = 0, [0][1] = 1, [1][0] = 2, [1][1] = 3
				// result: 4 tips about where zero cells, thus in different quarters
				if ($field[$i][$j] == 0) {
					$tips[((int)round($i/FIELD_H)) * 2 + (int)round($j/FIELD_W)] = array($i, $j);
				}
			}
		}
	}

	for ($i = 0; $i < count($tips); ++$i) {
		if ($tips[$i] !== false) {
			$game[$tips[$i][0]][$tips[$i][1]] = -1;
		}
	}
}
?>

<?php
//=======================================================================================
session_start();
if (empty($_SESSION)) {
	$_SESSION["wins"] = 0;
}

init_field($_SESSION["field"], $_SESSION["game"]);
$_SESSION["game_status"] = 0; // 0 - game, 1 - win, 2 - lose
$_SESSION["num_opened"] = 0;  // opened at now time cells
$_SESSION["time"] = -1;       // game not started
$_SESSION["flags"] = MINES;   // remaining flags

save_to_img($_SESSION["field"], $_SESSION["game"], session_id());
?>

<?php
include("html.php");
?>