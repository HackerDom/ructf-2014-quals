<?php
function get_img() {
	return "games/".session_id().".png";
}
function get_face($n) {
	return "images/face_".$n.".png";
}
function get_num($n) {
	return "numbers/".$n.".png";
}
//=======================================================================================
// help function. return index of image depends on status of game
//=======================================================================================
function img_index($game_val, $field_val, $gamover_flag) {
	// hardcore formulas
	$game_normal = array(
		-1 => 14,
		0 => 13,
		1 => $field_val,
		2 => 12
	);
	$game_gamover = array(
		-1 => 13,
		0 => $field_val == 9 ? 9 : 13,
		1 => $field_val,
		2 => $field_val == 9 ? 12 : 10,
		3 => 11
	);
	return $gamover_flag ? $game_gamover[$game_val] : $game_normal[$game_val];
}
//=======================================================================================
// from bitmap
//=======================================================================================
function create_images_from_bitmap($fname, $num, $w, $h) {
	$images = array();
	$big_image = imagecreatefrompng($fname);
	for ($i = 0; $i < $num; ++$i) {
		$images[] = imagecreate($w, $h);
		imagecopy($images[$i], $big_image, 0, 0, 0, ($num - $i - 1)*$h, $w, $h);
	}
	imagedestroy($big_image);
	return $images;
}
//=======================================================================================
// new image of game
//=======================================================================================
function save_to_img($field, $game, $filename, $gameover = false) {
	$images = create_images_from_bitmap("images/bitmaps.png", 15, CELL_SZ, CELL_SZ);
	
	//$dest = imagecreatetruecolor(FIELD_W*CELL_SZ, FIELD_H*CELL_SZ);
	$dest = imagecreatefrompng("noise/".rand(0, 24).".png");
	for ($i = 0; $i < FIELD_H; ++$i) {
		for ($j = 0; $j < FIELD_W; ++$j) {
			$img_ind = img_index($game[$i][$j], $field[$i][$j], $gameover);
			$img = $images[$img_ind];
			if ($game[$i][$j] == 1 && $field[$i][$j] != 0) {
				$color = imagecolorat($img, 9, 8);
				imagecolorset($img, $color, rand(220, 255), rand(220, 255), rand(200, 255));
			}
			imagecopy($dest, $img, $j*CELL_SZ, $i*CELL_SZ, 0, 0, CELL_SZ, CELL_SZ);
		}
	}
	imagepng($dest, "games/$filename.png");
	imagedestroy($dest);

	for ($i = 0; $i < 15; ++$i) {
		imagedestroy($images[$i]);
	}
}
//=======================================================================================
// numbers
//=======================================================================================
function make_noise(&$img) {
	for ($y = 0; $y < imagesy($img); ++$y) {
		for ($x = 0; $x < imagesx($img); ++$x) {
			$rgb["red"] = 96 + rand(-16, 40);
			$rgb["green"] = 96 + rand(-16, 40);
			$rgb["blue"] = 96 + rand(-16, 40);
			$cl = imagecolorallocate($img, $rgb["red"], $rgb["green"], $rgb["blue"]);
			imagesetpixel($img, $x, $y, $cl);
		}
	}
}
//=======================================================================================
// numbers
//=======================================================================================
function get_img_number($number) {
	$w = 13;
	$h = 23;
	$images = create_images_from_bitmap("images/number_bitmaps.png", 10, $w, $h);
	
	$number = $number % 1000;
	$digits = array(
		(int) ($number / 100),
		((int) ($number / 10)) % 10,
		$number % 10
	);

	$dest = imagecreatetruecolor($w*3, $h);
	for ($i = 0; $i < 3; ++$i) {
		$img = $images[$digits[$i]];
		imagecopy ($dest, $img, $i*$w, 0, 0, 0, $w, $h);
	}
	imagepng($dest, "numbers/$number.png");
	imagedestroy($dest);

	for ($i = 0; $i < 10; ++$i) {
		imagedestroy($images[$i]);
	}
}
/**/
?>