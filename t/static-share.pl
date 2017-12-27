use Mojolicious::Lite;
use Mojo::File qw(path);
use Mojo::Path;
use Mojo::Util qw(decode);

my $CONF = do './static-share.conf.pl';
#~ my $CONF = do './t/static-share.my.pl';
  #~ 'файл топиков'=> 'static-share.dirs.txt', # в 'админка папка'
  #~ 'админка адрес'=>'/админ',
  #~ 'админка папка'=>'/mnt/sda',
  #~ 'админка пароль'=>'**********',
  #~ 'шаблоны папка'=>'шаблоны',# в 'админка папка' '/mnt/sda/шаблоны'
  #~ 'корень папка'=>'корень',
  #~ mojo=>{
    #~ hypnotoad => {listen => ["http://*:80"], pid_file => "/home/guest/hypnotoad.pid", workers000 => 1,},
    #~ secrets=>['*************']
  #~ },
system('touch', "$CONF->{'админка папка'}/$CONF->{'файл топиков'}");
#~ my $shares = path(__FILE__)->sibling("$CONF->{'админка папка'}/$CONF->{'файл топиков'}");
my $shares = path("$CONF->{'админка папка'}/$CONF->{'файл топиков'}");
my @shares = map {decode('UTF-8', $_)} grep {!/^\s*#/} split /\n+/, $shares->slurp();
push @{app->renderer->paths}, "$CONF->{'админка папка'}/$CONF->{'шаблоны папка'}"
  if $CONF->{'шаблоны папка'};

#~ my $pid = $$;
my $nav = sub {# навигация админа
  my $c   = shift;
  my @items = (
    ['в /админ корень/'=>$CONF->{'админка адрес'}],
    ['в /абсолютный корень/'=>"/абсолютный корень"],
    map(["в /$_/" =>"/$_" ], @shares),
    ['редактировать ветки-топики'=>"$CONF->{'админка адрес'}/$CONF->{'файл топиков'}?edit=1"],
    ['редактировать конфиг сервиса'=>"/абсолютный корень/home/guest/static-share.conf.pl?edit=1"],
    ["перезапустить сервис (pid=$CONF->{mojo}{hypnotoad}{pid_file})"=>'/restart'],
    ['выключить комп'=>'/выключить'],
    ['выход из админа'=> '/logout'],
  );
  return $c->render_to_string('admin-nav', format=>'html', handler=>'ep', items=>\@items, );
};

my $admin_access = sub {
  my ($c,) = @_;
  return 1
    if $c->plugin->is_admin($c);
  
  return {template=>"static-share/login"};
};

# правильный порядок маршрутов!
app->plugin("StaticShare", root_dir=>'/', root_url=>'/абсолютный корень', admin_pass=>$CONF->{'админка пароль'}, admin_nav=>$nav, access=>$admin_access,);
my (undef, $adm_plugin) = app->plugin("StaticShare", root_dir=>$CONF->{'админка папка'}, root_url=>$CONF->{'админка адрес'}, admin_pass=>$CONF->{'админка пароль'}, admin_nav=>$nav, access=>$admin_access,);


get '/выключить' => sub {
  my $c   = shift;
  return $c->reply->not_found
    unless $adm_plugin->is_admin($c);
  system('(sleep 5 && sudo poweroff) & ');
  $c->render(text => "Комп выключается...", format=>'txt',);
};


get '/restart' => sub {
  my $c   = shift;
  return $c->reply->not_found
    unless $adm_plugin->is_admin($c);
  my $pid = path($CONF->{mojo}{hypnotoad}{pid_file})->slurp;
  my $k = kill 'USR2', $pid;
  #~ $c->render(text => "Процесс [$pid] перезапускается...", format=>'txt',);
  $c->redirect_to($CONF->{'админка адрес'});
};

get '/logout' => sub {
  my $c   = shift;
  # Delete whole session by setting an expiration date in the past
  $c->session(expires => 1);
  $c->redirect_to('/');
};

app->plugin("StaticShare", root_dir=>"$CONF->{'админка папка'}/$_", root_url=>"/$_", admin_pass=>$CONF->{'админка пароль'}, admin_nav=>$nav,  public_uploads=>1,)
  for @shares;
# этот маршрут последним!
app->plugin("StaticShare", root_dir=>"$CONF->{'админка папка'}/$CONF->{'корень папка'}", root_url=>"/", admin_pass=>$CONF->{'админка пароль'}, admin_nav=>$nav, public_uploads=>1,);

$ENV{MOJO_MAX_MESSAGE_SIZE}=0;
app->config($CONF->{mojo})
   ->secrets($CONF->{mojo}{secrets})
   ->start;

__DATA__

@@ admin-nav.html.ep
<nav class="right000 chip card000 green-forest lighten-3" style="position:absolute; right:0.5rem;">
  <a class="dropdown-button btn-flat white-text" style="padding: 0 0.5rem;" data-activates="admin-nav" href="javascript:" style="">админ</a>
  <ul id="admin-nav" class="dropdown-content">
  % for (@$items) {
    <li><a href="<%= $_->[1] %>" class="nowrap green-forest-text text-lighten-2"><%= $_->[0] %></a></li>
  % }
  </ul>
</nav>

@@ static-share/login.html.ep
% layout 'Mojolicious-Plugin-StaticShare/main';
<h2 class="">Администратор</h2>
<form method="get">
  <input type="text" name="admin">
  <input type="submit" value="Вход">
</form>

