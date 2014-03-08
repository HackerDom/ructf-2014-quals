<?php
  require_once 'common.php';

  if (array_key_exists('username', $_POST) && array_key_exists('password', $_POST))
  {
    $username = $_POST['username'];
    $password = $_POST['password'];
    $auth_result = try_auth($username, $password);
    if ($auth_result)
    {
      header('Location: index.php');
      exit;
    }
    else
      $error = '<span class="glyphicon glyphicon-remove"></span> Wrong username or password';
  }
?><!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="RuCTF secritter">
    <meta name="author" content="andgein">

    <title>Secritter :: Sign in</title>
    <link href="/static/css/bootstrap.min.css" rel="stylesheet">
    <link href="/static/css/style.css" rel="stylesheet">
  </head>

  <body>
    <div class="container">
      <form class="form-signin" role="form" method="POST">
        <h2 class="form-signin-heading">Please sign in</h2>
        <input type="text" class="form-control" placeholder="Username" required autofocus name="username" value="<?= isset($username) ? $username : '' ?>">
        <input type="password" class="form-control" placeholder="Password" required name="password">
        <?php if (isset($error))
              {
        ?>
        <div class="alert alert-danger"><?= $error ?></div>
        <?php } ?>
        <p>
          <button class="btn btn-lg btn-primary" type="submit">Sign in</button>
          <a class="btn btn-lg" type="button" href="registration.php">Sign up</a>
        </p>
        <p>
          <a class="btn btn-lg btn-success" type="button" href="connect.php">Sign in via Facebook</a>
        </p>
      </form>
    </div>
  </body>
</html>
