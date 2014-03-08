/*!
 * Snowing routine based on one <canvas> element dynamically 
 * injected in the background of the page.
 * 
 * The code is not optimized, feel free to make your own edits!
 *
 * Copyright 2010 by David Flanagan
 * http://creativecommons.org/licenses/by-nc-sa/3.0/
 *
 * Modified by Giorgio Sardo
 * http://blogs.msdn.com/Giorgio
 *
 * Modified by Konstantin Kichinskiy
 * http://habrahabr.ru/users/kichik/
 */
(function () {
	if(document.createElement('canvas').getContext) {
		if(document.readyState === 'complete')
			snow();
		else
			window.addEventListener('DOMContentLoaded', snow, false);
	}
	else {
		return;
	}

	var deg = Math.PI / 180;
	var maxflakes = 10; var flakes = []; var scrollspeed = 64; var snowspeed = 500;
	var canvas, sky;
	var snowingTimer;
	var invalidateMeasure = false;

	var strokes = ["#6cf", "#9cf", "#99f", "#ccf", "#66f", "#3cf"];

	function rand(n) {
		return Math.floor(n * Math.random());
	}

	// Запуск снегопада 
	function snow() {
		canvas = document.createElement('canvas');
		canvas.style.position = 'fixed';
		canvas.style.top = '0px';
		canvas.style.left = '0px';
		canvas.style.zIndex = '-10';

		document.body.insertBefore(canvas, document.body.firstChild);
		sky = canvas.getContext('2d');

		ResetCanvas();

		snowingTimer = setInterval(createSnowflake, snowspeed);
		setInterval(moveSnowflakes, scrollspeed);
		window.addEventListener('resize', ResetCanvas, false);
	}

	// Сброс размеров Canvas 
	function ResetCanvas() {
		invalidateMeasure = true;
		canvas.width = document.body.offsetWidth;
		canvas.height = window.innerHeight;
	}

	// Отрисовка кривой Коха 
	function leg(n, len) {
		sky.save();       // Сохраняем текущую трансформацию 
		if(n == 0) {      // Нерекурсивный случай - отрисовываем линию 
			sky.lineTo(len, 0);
		}
		else {
			sky.scale(1 / 3, 1 / 3);  // Уменьшаем масштаб в 3 раза 
			leg(n - 1, len); sky.rotate(60 * deg);
			leg(n - 1, len); sky.rotate(-120 * deg);
			leg(n - 1, len); sky.rotate(60 * deg); leg(n - 1, len);
		}
		sky.restore();      // Восстанавливаем трансформацию 
		sky.translate(len, 0); // переходим в конец ребра 
	}

	// Отрисовка снежинки Коха 
	function drawFlake(x, y, angle, len, n, stroke, fill) {
		sky.save(); sky.strokeStyle = stroke;
		sky.fillStyle = fill;
		sky.beginPath();
		sky.translate(x, y);
		sky.moveTo(0, 0); sky.rotate(angle);
		leg(n, len);
		sky.rotate(-120 * deg);
		leg(n, len); sky.rotate(-120 * deg);
		leg(n, len); sky.closePath();
		sky.fill();
		sky.stroke();
		sky.restore();
	}

	// Создание пула снежинок 
	function createSnowflake() {
		var order = 2 + rand(2);
		var size = 10 * order + rand(10);
		var x = rand(document.body.offsetWidth);
		var y = window.pageYOffset;
		var stroke = strokes[rand(strokes.length)];

		flakes.push({ x: x, y: y, vx: 0, vy: 3 + rand(3), angle: 0, size: size, order: order, stroke: stroke, fill: 'transparent' });

		if(flakes.length > maxflakes) clearInterval(snowingTimer);
	}

	// Перемещение снежинок 
	function moveSnowflakes() {
		sky.clearRect(0, 0, canvas.width, canvas.height);

		var maxy = canvas.height;

		for(var i = 0; i < flakes.length; i++) {
			var flake = flakes[i];

			flake.y += flake.vy;
			flake.x += flake.vx;

			if(flake.y > maxy) flake.y = 0;
			if(invalidateMeasure) {
				flake.x = rand(canvas.width);
			}

			drawFlake(flake.x, flake.y, flake.angle, flake.size, flake.order, flake.stroke, flake.fill);

			// Иногда меняем боковой ветер 
			if(rand(4) == 1) flake.vx += (rand(11) - 5) / 10;
			if(flake.vx > 2) flake.vx = 2;
			if(flake.vx < -2) flake.vx = -2;
			if(rand(3) == 1) flake.angle = (rand(13) - 6) / 271;
		}
		if(invalidateMeasure) invalidateMeasure = false;
	}
}());