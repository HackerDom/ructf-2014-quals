<?php
  require_once 'common.php';

  function get_url($url)
  {
    $curl = curl_init();
    curl_setopt($curl, CURLOPT_URL, $url);
    curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
    $data = curl_exec($curl);
    curl_close($curl);
    return $data;
  }

  if (! array_key_exists('code', $_GET))
    exit();

  if ($_GET['state'] != get_fb_state())
  {
    echo 'Invalid state: '.get_fb_state();
    exit();
  }

  $code = $_GET['code'];

  $url = 'https://graph.facebook.com/oauth/access_token?';
  $options = array('client_id' => $FB_APP_ID,
                   'redirect_uri' => 'http://'.$HOST.'/facebook.php',
                   'client_secret' => $FB_APP_SECRET,
                   'code' => $code);
  $url .= http_build_query($options, '', '&');
  
  $accessTokenString = get_url($url);
  $accessToken = false;
  $accessTokenArray = split('&', $accessTokenString);
  foreach ($accessTokenArray as $accessTokenStringPart)
  {
    $accessTokenPart = split('=', $accessTokenStringPart);
    if ($accessTokenPart[0] == 'access_token')
      $accessToken = $accessTokenPart[1];
  }

  if ($accessToken === false)
  {
    echo "Error";
    exit();
  }

  $meUrl = "https://graph.facebook.com/me?access_token=".$accessToken;
  $meInfo = json_decode(get_url($meUrl));
  $fb_id = $meInfo->{'id'};

  if (is_auth())
  {
    connect_fb($fb_id);
  }
  else
  {
    login_via_fb($fb_id);
  }
  header('Location: index.php');
?>