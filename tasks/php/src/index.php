<!doctype html>
<html>
<head>
  <style type="text/css">
    pre { width: 640px; white-space: normal; text-align: justify;};
  </style>
</head>
<body>
<center>
<h2>CTF</h2>
<?php
  header('Content-Type: text/html; charset=utf-8');
  $flag = '5cf27d9bad2fe9d96d2bcf25c3b0bd14';
  $ok   = 0;
  foreach(explode(',', $_SERVER['HTTP_ACCEPT_LANGUAGE']) as $s) {
    $l = explode(';', $s)[0];
    if (include $l) {
      $ok = 1;
      break;
    }
  }
  if (!$ok) {
    include 'en';
    echo 'Language was not detect automatically :(';
  } else {
    echo 'Language was detect automatically :)';
  }
?>
<center>
</body>
</html>
