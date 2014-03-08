<?php
  require_once 'common.php';

  if (! is_auth())
    exit();

  if (! array_key_exists('message', $_POST))
    exit();

  $message = $_POST['message'];

  if (strlen($message) > 140)
  {
    echo 'Too long message. Maximum length is 140 chars';
    exit();
  }

  /* TODO only acceptable chars in message */

  mysql_query('INSERT INTO messages (author, owner, message) VALUES ("'.mysql_real_escape_string(current_uid()).'", "'.mysql_real_escape_string(current_uid()).'", "'.mysql_real_escape_string($message).'")');

  header('Location: index.php');
?>