package Mojolicious::Plugin::StaticShare;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Asset::File;
use Mojo::Util qw (url_unescape decode );
use Mojolicious::Types;

our $VERSION = '0.01';
my $CONFIG;
my $mime = Mojolicious::Types->new;

sub register {
  my ($self, $app, $args) = @_;
  $CONFIG = $args;
  
  # Append class
  push @{$app->renderer->classes}, __PACKAGE__
    unless $args->{render_index} || $args->{render_markdown};
  #~ push @{$app->static->classes},   __PACKAGE__;
  
  my $route = $args->{route} || '/*path';
  die "Your config route doesnt match *path placeholder"
    unless $route =~ /\*path/;
  my $r = $app->routes;
  $r->get($route)->to(cb => \&get);
  $r->post($route)->to(cb => \&post);
  
  return $self;
}

sub get {
  my $c = shift;
  
  $c->stash('url_path', decode 'UTF-8',  url_unescape  $c->stash('path'));
  my $file_path = ($CONFIG->{root_dir} || './') . $c->stash('url_path');
  
  
  return dir($c, $file_path)
    if -d $file_path;
  return file($c, $path)
    if -e $file_path;
  
  $c->reply->not_found;
}

sub post {
  my $c = shift;
  
}

sub dir {
  my ($c, $path) = @_;
  
  #~ path($path)->list
  #~ return Mojo::Collection->new unless -d $$self;
  opendir(my $dir, $path)
    or return $c->reply->exception(qq{Can't open directory [$path]: $!});
  
  $c->stash('files', []);
  $c->stash('dirs', []);
  
  while (readdir $dir) {
    next
      if $_ eq '.' || $_ eq '..';
    next
      if /^\./; # unless $CONFIG->{hidden};
    
    push @{$c->stash('dirs')}, $_
      and next
      if -d "$path/$_";
    
    my @stat = stat "$path/$_";
    
    push @{$c->stash('files')}, {
      name  => $_,
      size  => $stat[7] || 0,
      type  => $mime->type(  (/\.([0-9a-zA-Z]+)$/)[0] || 'txt' ) || 'application/octet-stream',
      mtime => Mojo::Date->new( $stat[9] )->to_string(),
    };
  }
  closedir $dir;
  #~ return Mojo::Collection->new(map { $self->new($_) } sort @files);
  return $CONFIG->{render_index}
    ? $c->render(ref $CONFIG->{render_index} ? %{$CONFIG->{render_index}} : $CONFIG->{render_index},)
    : $c->render('.plugin/.static/.share/index',);
  
}

sub file {
  my ($c, $path) = @_;
  
  my $filename = path($path)->basename;
  
  $c->res->headers->content_disposition("attachment; filename=$filename;")
    if $c->param('attachment');
  #~ $c->res->headers->content_type('text/plain');
  $c->reply->asset(Mojo::Asset::File->new(path => $path));
  
}

sub markdown {
  my $c = shift;
  
  my $content;
  
  return $CONFIG->{render_markdown}
    ? $c->render(ref $CONFIG->{render_markdown} ? %{$CONFIG->{render_markdown}} : $CONFIG->{render_markdown}, content=>$content,)
    : $c->render('.plugin/.static/.share/markdown', content=>$content,);
  
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

=head2 route

One plugin route with L<Mojolicious::Guides::Routing#Wildcard-placeholders>. Defaults to '/*path'.

  route => '/my/share/*path',

=head2 admin_pass

Admin password (be sure https). None defaults.

  # any url like  https://myhost/my/share/foo/bar?admin=$%^!!9nes--
  admin_pass => '$%^!!9nes--', # 

=head2 render_index

Template path, format, handler, etc  which render directory index. Defaults builtin things.

  render_index => 'foo/bar'
  render_index => {template => 'foo/bar'},
  render_index => {template => 'foo/bar', handler=>'cgi.pl'},

  # Disable directory index
  render_index => undef, # or 0
  

=head2 render_markdown

Same as render_index but for markdown files. Defaults builtin things.

  # Disable markdown
  render_markdown => undef, # or 0


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

@@ layouts/.plugin/.static/.share/index.html.ep
<!DOCTYPE html>
<html>
<head>
<title><%= (stash('title') || stash('header-title'))  %></title>


%# http://realfavicongenerator.net
<link rel="apple-touch-icon" sizes="152x152" href="/apple-touch-icon.png">
<link rel="icon" type="image/png" href="/favicon-32x32.png" sizes="32x32">
<link rel="icon" type="image/png" href="/favicon-16x16.png" sizes="16x16">
<link rel="manifest" href="/manifest.json">
<link rel="mask-icon" href="/safari-pinned-tab.svg" color="#5bbad5">
<meta name="theme-color" content="#ffffff">


%# Материализные стили внутри main.css после слияния: sass --watch sass:css
%= stylesheet '/css/main.css'

<meta name="app:version" content="<%= stash('version') // 1 %>">

</head>
<body>
<header><div class="header clearfix"><%= stash('path')   %></div></header>
<main><div class="header clearfix"><%= content %></div></main>

%= javascript '/js/main.js'
%= javascript begin

$( document ).ready(function() {
  // console.log('Всем привет!');
});

% end

</body>
</html>

@@ .static/.share/index.html.ep
% layout '.plugin/.static/.share/index';

@@ .static/.share/markdown.html.ep
% layout '.plugin/.static/.share/index';

