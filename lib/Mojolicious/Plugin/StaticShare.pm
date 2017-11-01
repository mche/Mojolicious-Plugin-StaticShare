package Mojolicious::Plugin::StaticShare;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::File qw(path);
use Mojo::Asset::File;
use Mojo::Util qw (url_unescape decode encode );
use Mojolicious::Types;
use Mojo::Path;

our $VERSION = '0.01';

has qw(config);
has 'mime' => sub { Mojolicious::Types->new };

sub register {
  my ($self, $app, $args) = @_;
  $self->config($args);
  
  # Append class
  push @{$app->renderer->classes}, __PACKAGE__;
    #~ unless $args->{render_index} || $args->{render_markdown};
  #~ push @{$app->static->classes},   __PACKAGE__;
  
  my $route = $args->{route} || '/*path';
  die __PACKAGE__.": Your config route doesnt match *path placeholder"
    unless $route =~ /\*path/;
  my $r = $app->routes;
  $r->get('/')->to(cb => sub { $self->get(@_) }, path=>'',)->name('get static root')
    unless $args->{route};
  $r->get($route)->to(cb => sub { $self->get(@_) } )->name('get static path');
  $r->post($route)->to(cb => sub { $self->post(@_) } )->name('post static path');
  
  return $app;
}

sub get {
  my ($self,$c) = @_;
  
  #~ warn Mojo::Path->new(encode('UTF-8',  url_unescape($c->stash('path') || '')))->parse;
  
  $c->stash('url_path', encode('UTF-8',  url_unescape('/'.$c->stash('path'))));
  my $file_path = ($self->config->{root_dir} || '.') . $c->stash('url_path');
  #~ push @{ $file_path->parts }, $c->stash('url_path')
    #~ if $c->stash('path');
  $c->stash('file_path', $file_path);
  #~ warn "$file_path";
  
  
  return $self->dir($c, $file_path)
    if -d $file_path;
  return $self->file($c, $file_path)
    if -e $file_path;
  
  $c->reply->not_found;
}

sub post {
  my ($self,$c) = @_;
  
}

sub dir {
  my ($self, $c, $path) = @_;
  
  #~ path($path)->list
  #~ return Mojo::Collection->new unless -d $$self;
  opendir(my $dir, $path)
    or return $c->reply->exception(qq{Can't open directory [$path]: $!});
  
  $c->stash('files', []);
  $c->stash('dirs', []);
  $c->stash('parent_dir', decode('UTF-8', path($c->stash('url_path'))->dirname));
  
  while (readdir $dir) {
    next
      if $_ eq '.' || $_ eq '..';
    next
      if /^\./; # unless $CONFIG->{hidden};
    
    push @{$c->stash('dirs')}, decode('UTF-8', $_)
      and next
      if -d "$path/$_";
    
    my @stat = stat "$path/$_";
    
    push @{$c->stash('files')}, {
      name  => decode('UTF-8', $_),
      size  => $stat[7] || 0,
      #~ type  => $self->mime->type(  (/\.([0-9a-zA-Z]+)$/)[0] || 'txt' ) || 'application/octet-stream',
      mtime => Mojo::Date->new( $stat[9] )->to_string(),
    };
  }
  closedir $dir;
  #~ return Mojo::Collection->new(map { $self->new($_) } sort @files);
  return $self->config->{render_index}
    ? $c->render(ref $self->config->{render_index} ? %{$self->config->{render_index}} : $self->config->{render_index},)
    : $c->render('.plugin/.static/.share/dir',);
  
}

sub file {
  my ($self, $c, $path) = @_;
  
  my $filename = path($path)->basename;
  
  $c->res->headers->content_disposition("attachment; filename=$filename;")
    if $c->param('attachment');
  #~ $c->res->headers->content_type('text/plain');
  $c->reply->asset(Mojo::Asset::File->new(path => $path));
  
}

sub markdown {
  my ($self, $c) = @_;
  
  my $content;
  
  return $self->config->{render_markdown}
    ? $c->render(ref $self->config->{render_markdown} ? %{$self->config->{render_markdown}} : $self->config->{render_markdown}, content=>$content,)
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
<header><div class="header clearfix"><%= $path   %></div></header>
<main><div class="header clearfix"><%= content %></div></main>

%= javascript '/js/main.js'
%= javascript begin

$( document ).ready(function() {
  // console.log('Всем привет!');
});

% end

</body>
</html>

@@ .plugin/.static/.share/dir.html.ep
% layout '.plugin/.static/.share/index';
<h1>Index of <%= $path %></h1>
<hr />

<div class="row">

<div class="col s6">
<h2>Dirs</h2>

<h3>Parent <%= $parent_dir %></h3>

<ul>
  % for my $dir (sort  @$dirs) {
  <li class="dir"><a href='<%= $path.'/'.$dir %>'><%== $dir %></a></li>
  % }
</ul>

</div>

<div class="col s6">
<h2>Files</h2>

<table>
  <tr>
    <th class='name'>Name</th>
    <th class='size'>Size</th>
    <!--th class='type'>Type</th-->
    <th class='mtime'>Last Modified</th>
  </tr>
  % for my $file (sort { $a->{name} cmp $b->{name} } @$files) {
  <tr>
    <td class='name'><a href='<%= $path.'/'.$file->{name} %>'><%== $file->{name} %></a></td>
    <td class='size'><%= $file->{size} %></td>
    <!--td class='type'><%= $file->{type} %></td-->
    <td class='mtime'><%= $file->{mtime} %></td>
  </tr>
  % }
</table>

@@ plugin/.static/.share/markdown.html.ep
% layout '.plugin/.static/.share/index';

