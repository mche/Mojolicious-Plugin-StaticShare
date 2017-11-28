package Mojolicious::Plugin::StaticShare::Templates;
use utf8;

=pod

=encoding utf8

Доброго всем

=head1 Mojolicious::Plugin::StaticShare::Templates

¡ ¡ ¡ ALL GLORY TO GLORIA ! ! !

=head1 NAME

Mojolicious::Plugin::StaticShare::Templates - internal defaults templates.

=head1 TEMPLATES

=head2 layouts/Mojolicious-Plugin-StaticShare/main.html.ep

One main layout.

=head2 Mojolicious-Plugin-StaticShare/header.html.ep

One included header for templates.

=head2 Mojolicious-Plugin-StaticShare/dir.html.ep

Template for render dir content: subdirs, files, markdown index file.

=head2 Mojolicious-Plugin-StaticShare/markdown.html.ep

Template for render parsed content of markdown files.

=head2 Mojolicious-Plugin-StaticShare/pod.html.ep

Template for render parsed content of Perl pod files(.pod, .pl, .pm).

=head2 Mojolicious-Plugin-StaticShare/not_found.html.ep

Template for render 404.

=head2 Mojolicious-Plugin-StaticShare/exception.html.ep

Template for render 500.


=cut
1;
__DATA__

@@ layouts/Mojolicious-Plugin-StaticShare/main.html.ep
<!DOCTYPE html>
<html>
<head>
<title><%= stash('title')  %></title>


%# http://realfavicongenerator.net
<link rel="apple-touch-icon" sizes="152x152" href="/apple-touch-icon.png">
<link rel="icon" type="image/png" href="/favicon-32x32.png" sizes="32x32">
<link rel="icon" type="image/png" href="/favicon-16x16.png" sizes="16x16">
<link rel="manifest" href="/manifest.json">
<link rel="mask-icon" href="/safari-pinned-tab.svg" color="#5bbad5">
<meta name="theme-color" content="#ffffff">

<link href="/static-share/css/main.css" rel="stylesheet">

% if (stash('pod')) {
<style>

pre {
  background-color: #fafafa;
  border: 1px solid #c1c1c1;
  border-radius: 3px;
  font: 100% Consolas, Menlo, Monaco, Courier, monospace;
  padding: 1em;
}

:not(pre) > code {
  background-color: rgba(0, 0, 0, 0.04);
  border-radius: 3px;
  font: 0.9em Consolas, Menlo, Monaco, Courier, monospace;
  padding: 0.3em;
}

</style>
% }


<meta name="app:name" content="<%= stash('app:name') // 'Mojolicious::Plugin::StaticShare' %>">
%#<meta name="app:version" content="<%= stash('app:version') // 0.01 %>">
<meta name="url:version" content="<%= stash('app:version') // 0.01 %>">

</head>
<body class="white">

%= include 'Mojolicious-Plugin-StaticShare/header';

<main><div class="container clearfix"><%= stash('content') || content %></div></main>

<script src="/mojo/jquery/jquery.js"></script>
%#<script src="/js/dmuploader.min.js"></script>
<script src="/static-share/js/jquery.ui.widget.js"></script>
<script src="/static-share/js/jquery.fileupload.js"></script>
<script src="/static-share/js/velocity.min.js"></script>
<script src="/static-share/js/modal.js"></script>
<script src="/static-share/js/svg.js"></script>
<script src="/static-share/js/main.js"></script>

%= javascript begin
  ///console.log('Доброго всем!! ALL GLORY TO GLORIA');
% end

</body>
</html>

@@ Mojolicious-Plugin-StaticShare/dir.html.ep
% layout 'Mojolicious-Plugin-StaticShare/main';

<div class="row">
<div class="dirs-col col s6">

% if ($c->admin) {
<div class="right btn-panel" style="padding:1.2rem 0;">
  <a href="javascript:" class="hide renames"><svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 black-fill"  viewBox="0 0 26 26" data-include="svg:rename" /></a>
  <a href="javascript:" class="hide del-dirs"><svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 red-fill fill-lighten-1" viewBox="0 0 50 50" data-include="svg:dir-delete" /></a>
  <a id="add-dir" href="javascript:" class="btn-flat00" style="display:inline !important;">
    <svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 lime-fill fill-darken-4" viewBox="0 0 50 50" data-include="svg:add-dir" />
    <!--span class="lime-text text-darken-4"><%= i18n 'Add dir' %></span-->
  </a>
</div>

% }

<h2 class="lime-text text-darken-4">
%#  <svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 lime-fill fill-darken-4"  viewBox="0 0 30 30" data-include="svg:folder" />
%# <%= i18n 'Dirs' %>
  <svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 lime-fill fill-darken-4" viewBox="0 0 50 50" data-include="svg:down-right-round" />
  <span class=""><%= i18n 'Down' %></span>
  <span class="chip lime lighten-5" style=""><%= scalar @$dirs %></span>
</h2>

<div class="progress progress-dir white" style="margin:0; padding:0;">
    <div class="determinate lime" style="width: 0%"></div>
</div>

<ul class="collection dirs" style="margin-top:0;">
  <li class="collection-item dir lime darken-4 hide" style="position:relative;"><!-- template new folder -->
    <div class="input-field" style="padding-left:2rem; padding-right:4rem; position:relative;">
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 lime-fill fill-lighten-5" style="position:absolute; left:0; top:0.3rem;"  viewBox="0 0 30 30" data-include="svg:folder" />
      <input type="text" name="dir-name" class="" style="width:100%;" placeholder="<%= i18n 'new dir name'%>" >
      <a href="javascript:" _href="<%= $url_path->to_route %>" class="save-dir" style="position:absolute; right:2rem; top:0.3rem;">
        <svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 lime-fill fill-lighten-5"  viewBox="0 0 26 26" data-include="svg:upload" />
      </a>
    </div>
    <a class="lime-text text-darken-4 dir hide" style="display:block;">
      <svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 lime-fill fill-darken-4"  viewBox="0 0 30 30" data-include="svg:folder" />
      <span></span>
    </a>
    <div class="red-text error"></div>
    <input type="checkbox" name="dir-check"  class="" style="position:absolute; right:0.8rem; top:1rem;">
  </li>
  % for my $dir (sort  @$dirs) {
  % my $url = $url_path->clone->merge($dir)->trailing_slash(1)->to_route;
    <li class="collection-item dir lime lighten-5" style="position:relative;">
      <div class="input-field hide" style="padding-left:2rem; padding-right:4rem; position:relative;">
        <svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 lime-fill fill-darken-4" style="position:absolute; left:0; top:0.3rem;"  viewBox="0 0 30 30" data-include="svg:folder" />
        <input type="text" name="dir-name" class="" style="width:100%;" placeholder="<%= i18n 'new dir name'%>" value="<%== $dir %>">
        <a href="javascript:" _href="<%= $url %>" class="save-dir" style="position:absolute; right:2rem; top:0.3rem;">
          <svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 lime-fill fill-darken-4"  viewBox="0 0 26 26" data-include="svg:upload" />
        </a>
      </div>
       <a href="<%= $url %>" class="lime-text text-darken-4 dir" style="display:block;">
          <svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 lime-fill fill-darken-4"  viewBox="0 0 30 30" data-include="svg:folder" />
          <span><%== $dir %></span>
        </a>
      <div class="red-text error"></div>
% if ($c->admin) { # delete dir
        <input type="checkbox" name="dir-=check" style="position:absolute; right:0.8rem; top:1rem;">
% }
    </li>
  % }
</ul>

</div>

<div class="files-col col s6">

% if ($c->admin || $c->public_uploads) {
<div class="right btn-panel" style="padding:1.2rem 0;">
  <a href="javascript:" class="hide renames"><svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 black-fill"  viewBox="0 0 26 26" data-include="svg:rename"  /></a>
  <a href="javascript:" class="hide del-files"><svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 red-fill fill-lighten-1"  viewBox="0 0 26 26" data-include="svg:file-delete" /></a>
  <label for="fileupload" class="btn-flat000">
    <svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 light-blue-fill fill-darken-1" viewBox="0 0 26 26" data-include="svg:add-item"  />
    <!--span class="blue-text"><%= i18n 'Add uploads'%></span-->
  </label>
  <input id="fileupload" style="display:none;" type="file" name="file" data-url="<%= $url_path->clone->trailing_slash(0) %>" multiple>
  
</div>

% }

<h2 class="light-blue-text text-darken-2">
  <%= i18n 'Files'%>
  <span class="chip light-blue lighten-5" style=""><%= scalar @$files %></span>
</h2>

<div class="progress progress-file white" style="margin:0; padding:0;">
    <div class="determinate blue" style="width: 0%"></div>
</div>

<table class="striped files light-blue lighten-5" style="border: 1px solid #e0e0e0;">
%#<thead>
%#  <tr>
%#    <th class="name"><%= i18n 'Name'%></th>
%#    <th class="action" style="width:1%;"></th>
%#    <th class="size center"><%= i18n 'Size'%></th>
%#    <!--th class="type">Type</th-->
%#    <th class="mtime center"><%= i18n 'Last Modified'%></th>
%#  </tr>
%#</thead>
<thead class="hide">
  <tr class="light-blue"><!--- new upload file template -->
    <td class="chb">
      <input type="checkbox" name="file-check" class="" style="vertical-align: text-top;">
    </td>
    <td class="name">
      <a class="file-view hide"></a>
      <input type="text" name="file-name" value="" class="" style="width:100%;">
      <div class="red-text error"></div>
    </td>
    <td class="action">
      <a href="" class="file-download hide" style="padding:0.1rem;"><svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 light-blue-fill fill-darken-1" viewBox="0 0 26 26" data-include="svg:download" /></a>
      <a href="javascript:" _href="" class="file-rename hide" style="padding:0.1rem;"><svg xmlns="http://www.w3.org/2000/svg" class="icon icon15"  viewBox="0 0 26 26" data-include="svg:upload" /></a>
      <a href="javascript:" class="file-upload"><svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 white-fill"  viewBox="0 0 26 26" data-include="svg:upload" /></a>
    </td>
    <td class="size right-align fs8" ></td>
    <!--td class="type"></td-->
    <td class="mtime right-align fs8"></td>
  </tr>
</thead>
<tbody>
  % for my $file (sort { $a->{name} cmp $b->{name} } @$files) {
  % my $href = $url_path->clone->merge($file->{name})->to_route;
  <tr class="">
    <td class="chb">
% if ($c->admin) {
      <input type="checkbox" name="file-check"  class="" style="vertical-align: text-top;">
% }
    </td>

    <td class="name">
      <a href="<%= $href %>" class="file-view"><%== $file->{name} %></a>
      <input type="text" name="file-name" value="<%== $file->{name} %>" class="hide" style="width:100%;">
      <div class="red-text error hide"></div>
    </td>
    <td class="action">
      <a href="<%= $href %>?attachment=1" class="file-download" style="padding:0.1rem;"><svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 light-blue-fill fill-darken-1" viewBox="0 0 26 26" data-include="svg:download" /></a>
      <a href="javascript:" _href="<%= $href %>" class="file-rename hide" style="padding:0.1rem;"><svg class="icon icon15"  viewBox="0 0 26 26" data-include="svg:upload" /></a>

    </td>
    <td class="size right-align fs8" ><%= $file->{size} %></td>
    <!--td class="type"><%= $file->{type} %></td-->
    <td class="mtime right-align fs8"><%= $file->{mtime} %></td>
  </tr>
  % }
</tbody>
</table>

</div><!-- col 2 -->
</div><!-- row -->

% if (stash 'index') {
  <div class="right-align grey-text"><%= stash 'index' %></div>
% }
<div class="index"><%== stash('markdown') || stash('pod') || '' %></div>

%= include 'Mojolicious-Plugin-StaticShare/confirm-modal';

@@ Mojolicious-Plugin-StaticShare/header.html.ep

<header class="container clearfix">
<h1><%= i18n 'Index of'%>
% unless (@{$url_path->parts}) {
  <a href="<%= $url_path %>" class="chip grey-text grey lighten-4"><%= i18n 'root' %></a>
% }
% my $con;
% for my $part (@{$url_path->parts}) {
%   $con .="/$part";
  <a href="<%= $con %>" class="chip maroon-text maroon lighten-5"><%= $part %></a>
% }

% if ($c->plugin->root_url->to_route ne $url_path->to_route) {
  <a href="<%= $url_path->clone->trailing_slash(0)->to_dir %>" class="btn-flat000 ">
    <svg xmlns="http://www.w3.org/2000/svg" class="icon icon15 maroon-fill" viewBox="0 0 50 50" data-include="svg:up-left-round" />
    <span class="maroon-text"><%= i18n 'Up'%></span>
  </a>
% }

</h1>
<hr />
</header>


@@ Mojolicious-Plugin-StaticShare/markdown.html.ep
% layout 'Mojolicious-Plugin-StaticShare/main' unless layout;
<%== stash('markdown') || stash('content') || 'none content' %>

@@ Mojolicious-Plugin-StaticShare/pod.html.ep
% layout 'Mojolicious-Plugin-StaticShare/main' unless layout;
<%== stash('pod') || stash('content') || 'none content' %>

@@ Mojolicious-Plugin-StaticShare/not_found.html.ep
% layout 'Mojolicious-Plugin-StaticShare/main';
<h2 class="red-text">404 <%= i18n 'Not found'%></h2>

@@ Mojolicious-Plugin-StaticShare/exception.html.ep
% layout 'Mojolicious-Plugin-StaticShare/main';
% title i18n 'Error';

<h2 class="red-text">500 <%= i18n 'Error'%></h2>

% if(my $msg = $exception && $exception->message) {
%   utf8::decode($msg);
    <h3 id="error" style="white-space:pre;" class="red-text"><%= $msg %></h3>
% }


@@ Mojolicious-Plugin-StaticShare/confirm-modal.html.ep
<!-- Modal Structure -->
<div id="confirm-modal" class="modal bottom-sheet modal-fixed-footer">
  <div class="modal-header hide">
    <h2 class="red-text del-files"><span><%= i18n 'Confirm to delete these files' %></span><span class="chip red lighten-4"></span></h2>
    <h2 class="red-text del-dirs"><span><%= i18n 'Confirm to delete these dirs' %></span><span class="chip red lighten-4"></span></h2>
    <h2 class="red-text foo">Foo header</h2>
  </div>
  <div class="modal-content"></div>
  <div class="modal-footer green lighten-5">
    <a href="javascript:" class="modal-action modal-close green-text waves-effect waves-green btn-flat"><%= i18n 'I AM SURE' %></a>
  </div>
</div>
