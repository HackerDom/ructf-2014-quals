<?php
  /*
    Common function for secritter - absolute secret twitter.
  */

  $FB_APP_ID = '684919978239136';
  $FB_APP_SECRET = 'a322c9fea3ba8c5f4846850f38db5128';
  $HOST = 'ructf2014q-oauth.local';

  function connect()
  {
    $server = 'localhost';
    $username = 'secritter';
    $password = 'FEyYEs5QdMKXAZD9';
    $database = 'secritter';

    $db = mysql_connect($server, $username, $password);
    if (! $db)
      error('Can\'t connect to database');

    mysql_select_db($database, $db);
    mysql_query('SET NAMES utf8');
  }

  /* Auto-connect */
  connect();

  function error($msg)
  {
    echo 'Error: '.$msg;
    exit;
  }

  function auth_cookie_by_password_hash($password_hash)
  {
    return md5('COOKIE-SALT!@#$%^&*()'.$password_hash);
  }

  function hash_by_password($password)
  {
    return md5('PASSWORD-SALT!@#$%^&*()'.$password);
  }

  function get_user_by_uid($uid)
  {
    $uid = (int) $uid;
    $ans = mysql_query('SELECT * FROM users WHERE uid = '.$uid.' LIMIT 1');
    if (mysql_num_rows($ans) == 0)
      return false;
    return mysql_fetch_assoc($ans);
  }

  function get_user_by_username($username)
  {
    $ans = mysql_query('SELECT * FROM users WHERE username = "'.mysql_real_escape_string($username).'" LIMIT 1');
    if (mysql_num_rows($ans) == 0)
      return false;
    return mysql_fetch_assoc($ans);
  }

  function is_auth()
  {
    if (! array_key_exists('auth', $_COOKIE) || ! array_key_exists('uid', $_COOKIE))
      return false;

    $uid = (int) $_COOKIE['uid'];
    $auth_cookie = $_COOKIE['auth'];
    $user = get_user_by_uid($uid);
    if ($user === false)
      return false;

    return $auth_cookie == auth_cookie_by_password_hash($user['password']);
  }

  function current_uid()
  {
    if (! is_auth())
      return false;
    return (int) $_COOKIE['uid'];
  }

  function current_user()
  {
    if (! is_auth())
      return false;
    return get_user_by_uid(current_uid());
  }

  function set_auth_cookies($uid, $password_hash)
  {
    setcookie('uid', $uid);
    $_COOKIE['uid'] = $uid;
    setcookie('auth', auth_cookie_by_password_hash($password_hash));
    $_COOKIE['auth'] = auth_cookie_by_password_hash($password_hash);
  }

  function try_auth($username, $password)
  {
    $user = get_user_by_username($username);
    if ($user === false)
      return false;
    $success = $user['password'] == hash_by_password($password);
    
    if ($success)
      set_auth_cookies($user['uid'], $user['password']);

    return $success;
  }

  function try_create_account($username, $password)
  {
    mysql_query('START TRANSACTION');
    if (get_user_by_username($username) !== false)
      return false;
    $password_hash = hash_by_password($password);
    $ans = mysql_query('INSERT INTO users (username, password, fb_id) VALUES ("'.mysql_real_escape_string($username).'", "'.
                                                                                 mysql_real_escape_string($password_hash).'", NULL)');
    mysql_query('COMMIT');
    return $ans !== false;
  }

  function get_fb_state()
  {
    if (! is_auth())
      return md5('any');
    $ans = mysql_query('SELECT fb_state FROM users WHERE uid="'.mysql_real_escape_string(current_uid()).'" LIMIT 1');
    while ($a = mysql_fetch_assoc($ans))
      return $a['fb_state'];
    return '';
  }

  function fb_auth_link()
  {
    global $FB_APP_ID, $HOST;
    $fb_state = '';
    for ($i = 0; $i < 100; ++$i)
      $fb_state .= chr(ord('a') + rand(0, 25));
    $fb_state = md5($fb_state);
    mysql_query('UPDATE users SET fb_state="'.mysql_real_escape_string($fb_state).'" WHERE uid="'.mysql_real_escape_string(current_uid()).'"');    
    return 'https://www.facebook.com/dialog/oauth?client_id='.$FB_APP_ID.'&redirect_uri=http://'.$HOST.'/facebook.php&state='.get_fb_state();
  }

  function connect_fb($fb_id)
  {
    if (! is_auth())
      return false;

    $uid = current_uid();
    mysql_query('UPDATE users SET fb_id="'.mysql_real_escape_string($fb_id).'", fb_state="" WHERE uid="'.mysql_real_escape_string($uid).'"');
  }

  function login_via_fb($fb_id)
  {
    if (is_auth())
      return false;

    $ans = mysql_query('SELECT uid FROM users WHERE fb_id = "'.mysql_real_escape_string($fb_id).'" LIMIT 1');
    while ($a = mysql_fetch_assoc($ans))
    {
      $uid = $a['uid'];
      $user = get_user_by_uid($uid);
      set_auth_cookies($uid, $user['password']);
    }
  }

  function get_messages($uid)
  {
    $user = get_user_by_uid($uid);

    $messages = array();
    $ans = mysql_query('SELECT * FROM messages JOIN users ON messages.author = users.uid WHERE owner="'.mysql_real_escape_string($uid).'" OR message LIKE "%@'.mysql_real_escape_string($user['username']).'%" ORDER BY mid DESC');
    while ($a = mysql_fetch_assoc($ans))
    {
      $messages[] = $a;
    }
    return $messages;
  }
?>