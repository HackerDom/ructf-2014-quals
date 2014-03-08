use Mojolicious::Lite;

my $es = Mojo::URL->new('http://localhost:9200/');

app->config(hypnotoad => {listen => ['http://*:80'], user => 'es', group => 'es'});
app->secrets(['ructf']);

get '/' => sub { shift->render } => 'index';
get '/register' => sub { shift->render } => 'register';

post '/short' => sub {
  my $self = shift;
  $self->render_later;

  $self->app->ua->post($es->path('/es/url/') => json => {
      url => $self->req->param('url'), name => $self->session('name') // 'noname'
    }, sub {
      my ($ua, $tx) = @_;
      $self->flash(id => $tx->res->json('/_id'));
      $self->redirect_to('index');
  });
} => 'short';

get '/logout' => sub {
  my $self = shift;

  $self->session(expires => 1);
  $self->redirect_to('index');
} => 'logout';

post '/login' => sub {
  my $self = shift;
  $self->render_later;

  my ($n, $p) = ($self->req->param('name'), $self->req->param('pass'));

  $self->app->ua->get($es->path("/es/user/$n"), sub {
      my ($ua, $tx) = @_;

      $self->session(name => $n) if $tx->res->json('/_source/pass') // '' eq $p;
      $self->redirect_to('index');
  });
} => 'login';

get '/list' => sub {
  my $self = shift;
  $self->render_later;

  return $self->render_not_found unless my $name = $self->session('name');

  $self->app->ua->post($es->path('/es/url/_search') => json => {
      filter => {
        term => { name => $name }
      }
    }, sub {
      my ($ua, $tx) = @_;

      $self->stash(list => $tx->res->json('/hits/hits'));
      $self->render;
  });
} => 'list';

post '/register' => sub {
  my $self = shift;
  $self->render_later;

  $self->app->ua->post($es->path(sprintf '/es/user/%s', $self->req->param('name')) => json => {
    name => $self->req->param('name'), pass => $self->req->param('pass')
  }, sub {
    my ($ua, $tx) = @_;

    return $self->render_exception unless $tx->res->json('/created');

    $self->session(name => $tx->res->json('/_id'));
    $self->redirect_to('index');
  });
} => 'register';

get '/super/secret/flag' => sub {
  shift->render(text => 'f1264d450b9feda62fec5a1e11faba1a');
};

get '/:short' => sub {
  my $self = shift;
  $self->render_later;

  $self->app->ua->get($es->path(sprintf '/es/url/%s', $self->stash('short')), sub {
    my ($ua, $tx) = @_;

    return $self->render_not_found unless $tx->res->json('/found');
    $self->redirect_to($tx->res->json('/_source/url'));
  });
} => 'r';

app->start;

__DATA__

@@ layouts/main.html.ep

<!DOCTYPE html>
<html>
  <head>
    <title>ElasticShortener</title>
    <style>
      body { margin-left: 300px; }
      #short { margin-top: 200px; margin-left: -300px; }
      #short input { width: 500px; }
    </style>
  </head>
  <body>
    <!-- secret: ructf -->
    % if (my $name = session 'name') {
      <p>Hi, <%= $name %>!</p>
      <p><a href="<%= url_for('logout') %>">logout</a></p>
      % if (current_route ne 'list') {
        <p><a href="<%= url_for('list') %>">list</a></p>
      % } else {
        <p><a href="<%= url_for('index') %>">main</a></p>
      % }
    % } else {
      <p>Hi, noname!</p>
      % if (current_route ne 'register') {
        <form method="POST" action="<%= url_for 'login' %>">
          <input type="text" name="name">
          <input type="text" name="pass">
          <button>login</button>
        </form>
        <a href="<%= url_for('register') %>">register</a>
      % }
    % }
    <%= content %>
  </body>
</html>

@@ index.html.ep

% layout 'main';

<center id="short">
% if (my $id = flash 'id') {
  <p><a href="<%= url_for('r', short => $id) %>"><%= url_for('r', short => $id) %></a></p>
% } else {
  <form action="<%= url_for 'short' %>" method="POST">
    <input type="text" name="url">
    <button>short!</button>
  </form>
% }
</center>

@@ register.html.ep

% layout 'main';

<form method="POST" action="<%= url_for 'register' %>">
  <input type="text" name="name">
  <input type="text" name="pass">
  <button>register</button>
</form>

@@ list.html.ep

% layout 'main';

<ol>
  % for (@$list) {
    <li><a href="<%= url_for('r', short => $_->{_source}{url}) %>"><%= url_for('r', short => $_->{_source}{url}) %></a></li>
  % }
</ol>
