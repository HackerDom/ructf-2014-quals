<?php
  require_once 'common.php';

  if (! is_auth())
  {
    header('Location: login.php');
    exit;
  }

  $user = current_user();
?><!DOCTYPE html>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="RuCTF secritter">
    <meta name="author" content="andgein">

    <title>Secritter :: Main</title>
    <link href="/static/css/bootstrap.min.css" rel="stylesheet">
    <link href="/static/css/style.css" rel="stylesheet">
  </head>

  <body class="with-navbar">
    <div class="navbar navbar-inverse navbar-fixed-top" role="navigation">
      <div class="container-fluid">
        <div class="navbar-header">
          <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
            <span class="sr-only">Toggle navigation</span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#">Secritter &mdash; absolutely private & secret twitter</a>
        </div>
        <div class="navbar-collapse collapse">
          <ul class="nav navbar-nav navbar-right">
            <li><a href="">You are logged in as @<?= $user['username'] ?><?= $user['fb_id'] ? ', your profile is connected to FB ID: '.$user['fb_id'] : '' ?></a></li>
            <li><a href="connect.php">Connect to FB</a></li>
            <li><a href="logout.php">Logout</a></li>
          </ul>
        </div>
      </div>
    </div>


    <div class="container">

      <form class="form-inline" role="form" action="post.php" method="POST">
        <div class="form-group">
          <label><b>@<?= $user['username'] ?>:</b></label> <input type="text" name="message" class="form-control" maxlength=140 size=140>
        </div>
        <button type="submit" class="btn btn-success">Post</button>
      </form>

      <div>&nbsp;</div>
<?php
    $messages = get_messages($user['uid']);
    foreach ($messages as $message)
    {
    ?>    
      <div class="well">
        <b>@<?= $message['username'] ?></b>: <?= $message['message'] ?>
      </div>
    <?php
    }
?>
  </div>
  <script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
  <script src="/static/js/bootstrap.min.js"></script>
</body>