<?php
  require_once 'common.php';

  if (array_key_exists('username', $_POST) && array_key_exists('password', $_POST))
  {
    $username = $_POST['username'];
    $password = $_POST['password'];

    $result = try_create_account($username, $password);
    if ($result)
    {
      try_auth($username, $password);
      header('Location: index.php');
    }
    else
      $error = '<span class="glyphicon glyphicon-remove"></span> Can\'t create account. Maybe another user with same login already exists.';
  }
?><!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="RuCTF secritter">
    <meta name="author" content="andgein">

    <title>Secritter :: Sign up</title>
    <link href="/static/css/bootstrap.min.css" rel="stylesheet">
    <link href="/static/css/style.css" rel="stylesheet">
  </head>

  <body>
    <div class="container">
      <form class="form-signin" role="form" method="POST">
        <h2 class="form-signin-heading">Registration form</h2>
        <input type="text" class="form-control" placeholder="Username" required autofocus name="username" value="<?= isset($username) ? $username : '' ?>">
        <input type="password" class="form-control" placeholder="Password" required name="password">
        <?php if (isset($error))
              {
        ?>
        <div class="alert alert-danger"><?= $error ?></div>
        <?php } ?>
        <button class="btn btn-lg btn-primary" type="submit">Sign up</button>
        <a class="btn btn-lg" type="button" href="login.php">Sign in</a>
      </form>
    </div>
  </body>
</html>
