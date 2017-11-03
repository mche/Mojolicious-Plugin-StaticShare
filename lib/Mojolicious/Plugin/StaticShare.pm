package Mojolicious::Plugin::StaticShare;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::File qw(path);
use Mojo::Asset::File;
use Mojo::Util qw (url_unescape decode encode );
use Mojolicious::Types;
use Mojo::Path;
#~ use Mojolicious::Plugin::StaticShare::Static;
use HTTP::AcceptLanguage;
use Time::Piece;# module replaces the standard localtime and gmtime functions with implementations that return objects

our $VERSION = '0.01';

has qw(config);
has mime => sub { Mojolicious::Types->new };

sub register {
  my ($self, $app, $args) = @_;
  $self->config($args);
  
  require Mojolicious::Plugin::StaticShare::Static
    and push @{$app->renderer->classes}, __PACKAGE__."::Static"
    and push @{$app->static->classes},   __PACKAGE__."::Static"
    unless defined($args->{render_dir}) && $args->{render_dir} eq 0
          && defined($args->{render_markdown}) && $args->{render_markdown} eq 0;
  
  $args->{root_url} ||= '';
  $args->{root_url}  =~ s|/$||;
  
  my $route = "$args->{root_url}/*path";
  #~ die __PACKAGE__.": Your config route doesnt match *path placeholder"
    #~ unless $route =~ /\*path/;
  my $r = $app->routes;
  $r->get($args->{root_url})->to(cb => sub { $self->get(@_) }, path=>'',)->name('Plugin-StaticShare-ROOT');
  $r->post($args->{root_url})->to(cb => sub { $self->post(@_) }, path=>'',)->name('Plugin-StaticShare-ROOT-POST');
  $r->get($route)->to(cb => sub { $self->get(@_) } )->name('Plugin-StaticShare-GET');
  $r->post($route)->to(cb => sub { $self->post(@_) } )->name('Plugin-StaticShare-POST');

  $app->helper(лок => sub { &лок(@_) });
  
  return $app;
}

my %loc = (
  'ru'=>{'Not found'=>"Не найдено", 'Disabled index of'=>"Заблокирован вывод содержания",  'Share'=>'Обзор', 'Index of'=>'Содержание', 'Dirs'=>'Каталоги', 'Files'=>'Файлы', 'Name'=>'Название файла', 'Size'=>'Размер', 'Last Modified'=>'Дата изменения', 'Up'=>'Выше', 'Add file'=>'Добавить файл'},
);
sub лок {# helper
  my ($c, $str, $lang) = @_;
  #~ $lang //= $c->stash('language');
  my $loc; $loc = $loc{$_}
    and last
    for $c->stash('language')->languages;
  
  return $loc->{$str} || $loc->{lc $str} || $str
    if $loc;
  return $str;
}

sub get {
  my ($self,$c) = @_;
  
  #~ $c->stash('root_url', $self->config->{root_dir});
  my $lang = HTTP::AcceptLanguage->new($c->req->headers->accept_language || 'en;q=0.5');
  $c->stash('language' => $lang);
  $c->stash('title' => $c->лок('Share'));
  #~ $c->stash('title' => 'Обзор')
    #~ if $lang->match(qw/ ru /);
  
  $c->stash('path' => path('/'.$c->stash('path') =~ s|/$||r))
    if $c->stash('path');
  $c->stash('url_path' => Mojo::Path->new($self->config->{root_url} . $c->stash('path')));
  my $file_path = ($self->config->{root_dir} || '.') . encode('UTF-8',  url_unescape($c->stash('path')));#$c->stash('url_path');
  
  return $self->dir($c, $file_path)
    if -d $file_path;
  return $self->file($c, $file_path)
    if -e $file_path;

  $c->render_maybe('Mojolicious-Plugin-StaticShare/not_found', status=>404,)
    or $c->reply->not_found;
}

sub post {
  my ($self,$c) = @_;
  
  $c->render(json=>'ok');
}

sub dir {
  my ($self, $c, $path) = @_;
  
  #~ path($path)->list
  #~ return Mojo::Collection->new unless -d $$self;
  opendir(my $dir, $path)
    or return $c->reply->exception(qq{Can't open directory [$path]: $!});
  
  my $files = $c->stash('files' => [])->stash('files');
  my $dirs = $c->stash('dirs' => [])->stash('dirs');
  #~ $c->stash('parent_dir' => decode('UTF-8', path($c->stash('url_path'))->dirname));
  
  while (readdir $dir) {
    next
      if $_ eq '.' || $_ eq '..';
    next
      if /^\./; # unless $CONFIG->{hidden};
    
    push @$dirs, decode('UTF-8', $_)
      and next
      if -d "$path/$_";
    
    my @stat = stat "$path/$_";
    
    push @$files, {
      name  => decode('UTF-8', $_),
      size  => $stat[7] || 0,
      #~ type  => $self->mime->type(  (/\.([0-9a-zA-Z]+)$/)[0] || 'txt' ) || 'application/octet-stream',
      mtime => decode 'UTF-8', localtime( $stat[9] )->strftime, #->to_datetime, #to_string(),
    };
  }
  closedir $dir;
  #~ return Mojo::Collection->new(map { $self->new($_) } sort @files);
  return $c->render(ref $self->config->{render_dir} ? %{$self->config->{render_dir}} : $self->config->{render_dir},)
    if $self->config->{render_dir}; 
  
  unless (defined($self->config->{render_dir}) && $self->config->{render_dir} eq 0) {
    $c->render_maybe("Mojolicious-Plugin-StaticShare/$_/dir")
      and return
      for $c->stash('language')->languages;
    
    return $c->render('Mojolicious-Plugin-StaticShare/en/dir',);
  }
  
  $c->render_maybe('Mojolicious-Plugin-StaticShare/exception', status=>500,)
    or $c->reply->exception;

  
}

sub file {
  my ($self, $c, $path) = @_;
  
  my $filename = path($path)->basename;
  
  $c->res->headers->content_disposition($c->param('attachment') ? "attachment; filename=$filename;" : "inline");
  my $type  =$self->mime->type(  ( $path =~ /\.([0-9a-zA-Z]+)$/)[0] || 'txt' ) || $self->mime->type('txt');#'application/octet-stream';
  $c->res->headers->content_type($type);
  $c->reply->asset(Mojo::Asset::File->new(path => $path));
  
}

sub markdown {
  my ($self, $c) = @_;
  
  my $content;
  
  return $self->config->{render_markdown}
    ? $c->render(ref $self->config->{render_markdown} ? %{$self->config->{render_markdown}} : $self->config->{render_markdown}, content=>$content,)
    : $c->render('Mojolicious-Plugin-StaticShare/markdown', content=>$content,);
  
}

1;
=pod

=encoding utf8

Доброго всем

=head1 Mojolicious::Plugin::StaticShare

¡ ¡ ¡ ALL GLORY TO GLORIA ! ! !

=head1 NAME

Mojolicious::Plugin::StaticShare - browse, upload, copy, move, delete static files/dirs.

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin('StaticShare', <options>);

  # Mojolicious::Lite
  plugin 'StaticShare', <options>;
  
  # oneliner
  > perl -Mojo -E 'a->plugin("StaticShare")->start' daemon


=head1 DESCRIPTION

This plugin for share static files/dirs and has two interfaces: public and admin:

=head2 Public interface

Can browse and put files if name not exists.

=head2 Admin interface

Can copy, move, delete files/dirs

Place param 'admin=<admin_pass option>' to any http url for plugin route option (see below).

=head1 OPTIONS

=head2 root_dir

Absolute or relative file system path root directory. Defaults to '.'.

  root_dir => '/mnt/usb',
  root_dir => 'here', 

=head2 root_url

This prefix to url path. Defaults to '/'.

  root_url => '/', # mean route /*path
  root_url => '', # mean also route /*path
  root_url => '/my/share', # mean route /my/share/*path

See L<Mojolicious::Guides::Routing#Wildcard-placeholders>.

=head2 admin_pass

Admin password (be sure https). None defaults.

  # any url like  https://myhost/my/share/foo/bar?admin=$%^!!9nes--
  admin_pass => '$%^!!9nes--', # 

=head2 render_dir

Template path, format, handler, etc  which render directory index. Defaults builtin things.

  render_dir => 'foo/bar'
  render_dir => {template => 'foo/bar'},
  render_dir => {template => 'foo/bar', handler=>'cgi.pl'},

  # Disable directory index
  render_dir => 0,
  

=head2 render_markdown

Same as render_dir but for markdown files. Defaults builtin things.

  # Disable markdown
  render_markdown => 0,


=head1 METHODS

L<Mojolicious::Plugin::StaticShare> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious::Plugin::Directory>

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicious.org>.

=head1 AUTHOR

Михаил Че (Mikhail Che), C<< <mche[-at-]cpan.org> >>

=head1 BUGS / CONTRIBUTING

Please report any bugs or feature requests at L<https://github.com/mche/Mojolicious-Plugin-StaticShare/issues>. Pull requests also welcome.

=head1 COPYRIGHT

Copyright 2017 Mikhail Che.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__DATA__



