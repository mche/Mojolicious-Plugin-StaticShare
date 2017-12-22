use Mojolicious::Lite;
use Mojo::File qw(path);
use Mojo::Path;
use Mojo::Util qw(decode);


my %CONF = (
  'файл топиков'=> 'static-share.dirs.txt', # в 'админка папка'
  'админка адрес'=>'/админ',
  'админка папка'=>'t',#/mnt/sda/
  'админка пароль'=>123,# 111-333+159
  'шаблоны папка'=>'шаблоны',# в 'админка папка' '/mnt/sda/шаблоны'
  'корень папка'=>'корень',
  mojo=>{
    hypnotoad => {listen => ["http://*:3003"], pid_file => "t/static-share-hypnotoad.pid", workers000 => 1,},
  },

);
system('touch', "$CONF{'админка папка'}/$CONF{'файл топиков'}");
#~ my $shares = path(__FILE__)->sibling("$CONF{'админка папка'}/$CONF{'файл топиков'}");
my $shares = path("$CONF{'админка папка'}/$CONF{'файл топиков'}");
my @shares = map {decode('UTF-8', $_)} grep {!/^\s*#/} split /\n+/, $shares->slurp();

my $nav = sub {# навигация админа
  my $c   = shift;
  my @items = (
    ['в /админ/'=>$CONF{'админка адрес'}],
    ['в /файловый корень/'=>"/абсолютный корень"],
    map(["в /$_/" =>"/$_" ], @shares),
    ['редактировать конфиг'=>"$CONF{'админка адрес'}/$CONF{'файл топиков'}?edit=1"],
    ['перезапустить конфиг'=>'/restart'],
    ['выключить комп'=>'/выключить'],
  );
  return $c->render_to_string('admin-nav', format=>'html', handler=>'ep', items=>\@items, );
};

app->plugin("StaticShare", root_dir=>'/', root_url=>'/абсолютный корень', admin_pass=>$CONF{'админка пароль'}, admin_nav=>$nav,);
my ($app, $adm_plugin) = app->plugin("StaticShare", root_dir=>$CONF{'админка папка'}, root_url=>$CONF{'админка адрес'}, admin_pass=>$CONF{'админка пароль'}, admin_nav=>$nav,);
push @{app->renderer->paths}, "$CONF{'админка папка'}/$CONF{'шаблоны папка'}";


$adm_plugin->access(sub {
  my ($c,) = @_;
  return $adm_plugin->is_admin($c);
  
});

get '/выключить' => sub {
  my $c   = shift;
  return $c->reply->not_found
    unless $adm_plugin->is_admin($c);
  system('(sleep 5 && sudo poweroff) & ');
  $c->render(text => "Комп выключается...", format=>'txt',);
};

my $pid = $$;
get '/restart' => sub {
  my $c   = shift;
  return $c->reply->not_found
    unless $adm_plugin->is_admin($c);
  my $k = kill 'USR2', $pid;
  #~ $c->render(text => "Процесс [$pid] перезапускается...", format=>'txt',);
  $c->redirect_to($CONF{'админка адрес'});
};

app->plugin("StaticShare", root_dir=>"$CONF{'админка папка'}/$_", root_url=>"/$_", admin_pass=>$CONF{'админка пароль'}, admin_nav=>$nav,  public_uploads=>1,)
  for @shares;
# этот маршрут последним!
app->plugin("StaticShare", root_dir=>"$CONF{'админка папка'}/$CONF{'корень папка'}", root_url=>"/", admin_pass=>$CONF{'админка пароль'}, admin_nav=>$nav, public_uploads=>1,);

$ENV{MOJO_MAX_MESSAGE_SIZE}=0;
app->config($CONF{mojo})
  ->secrets(['21--332++34'])
  ->start;

__DATA__

@@ admin-nav.html.ep
<nav class="right000 chip green-forest" style="position:absolute; right:0.5rem;">
  <a class="dropdown-button white-text" data-activates="admin-nav" href="javascript:" style="">админ</a>
  <ul id="admin-nav" class="dropdown-content">
  % for (@$items) {
    <li><a href="<%= $_->[1] %>" class="nowrap green-forest-text"><%= $_->[0] %></a></li>
  % }
  </ul>
</nav>

