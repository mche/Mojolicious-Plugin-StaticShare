package Mojolicious::Plugin::StaticShare::Templates;
use utf8;

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

<link href="/css/main.css" rel="stylesheet">


<meta name="app:name" content="<%= stash('app:name') // 'Mojolicious::Plugin::StaticShare' %>">
<meta name="app:version" content="<%= stash('app:version') // 0.01 %>">

</head>
<body class="white">

%= include 'Mojolicious-Plugin-StaticShare/svg';

<header><div class="header clearfix"><%= stash('header-content')   %></div></header>
<main><div class="container clearfix"><%= stash('content') || content %></div></main>

<script src="/mojo/jquery/jquery.js"></script>
%#<script src="/js/dmuploader.min.js"></script>
<script src="/js/jquery.ui.widget.js"></script>
<script src="/js/jquery.fileupload.js"></script>
<script src="/js/plugin-static-share.js"></script>

%= javascript begin
// Доброго всем
// ALL GLORY TO GLORIA

% end

</body>
</html>

@@ Mojolicious-Plugin-StaticShare/en/dir.html.ep
% layout 'Mojolicious-Plugin-StaticShare/main';

%= include 'Mojolicious-Plugin-StaticShare/header';

<div class="row">
<div class="col s6">

<h2 class="lime-text text-darken-4">
  <svg class="icon icon15 lime-fill fill-darken-4"><use xlink:href="#svg:folder"></svg>
  <%= лок 'Dirs'%>
  <span class="chip lime lighten-5" style=""><%= scalar @$dirs %></span>
</h2>



<ul class="collection dirs">
  % for my $dir (sort  @$dirs) {
    <li class="collection-item dir lime lighten-5">
      <a href="<%= $url_path.'/'.$dir %>" class="lime-text text-darken-4" style="display:block;">
        <svg class="icon icon15 lime-fill fill-darken-4"><use xlink:href="#svg:folder"></svg>
        <%== $dir %>
      </a>
      
    </li>
  % }
</ul>

</div>

<div class="col s6">

<div class="right" style="padding:0.7rem 0;">
  <label for="fileupload" class="btn-flat">
    <svg class="icon icon15 light-blue-fill fill-darken-1"><use xlink:href="#svg:add-file" /></svg>
    <span class="blue-text"><%= лок 'Add uploads'%></span>
  </label>
  <input id="fileupload" style="display:none;" type="file" name="file" data-url="<%= $url_path %>" multiple>
  
</div>

<h2 class="light-blue-text text-darken-2">
  <%= лок 'Files'%>
  <span class="chip light-blue lighten-5" style=""><%= scalar @$files %></span>
</h2>



<div class="progress white" style="margin:0; padding:0;">
    <div class="determinate blue" style="height: 18px; width: 0%"></div>
</div>


<table class="striped files light-blue lighten-5">
<thead>
  <tr>
    <th class="name"><%= лок 'Name'%></th>
    <th class="action" style="width:1%;"></th>
    <th class="size center"><%= лок 'Size'%></th>
    <!--th class="type">Type</th-->
    <th class="mtime center"><%= лок 'Last Modified'%></th>
  </tr>
</thead>
<tbody>
  % for my $file (sort { $a->{name} cmp $b->{name} } @$files) {
  <tr>
    <td class="name">
      <a href="<%= $url_path.'/'.$file->{name} %>"><%== $file->{name} %></a>
    </td>
    <td class="action">
%# if ($file->{mode}) {
        <a href="<%= $url_path.'/'.$file->{name} %>?attachment=1" class="" style="padding:0.1rem;"><svg class="icon icon15 light-blue-fill fill-darken-1"><use xlink:href="#svg:download" /></a>
%# }
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

<div class="markdown"><%== stash('markdown') || '' %></div>

@@ Mojolicious-Plugin-StaticShare/header.html.ep

<h1><%= лок 'Index of'%>
% my $pc = @{$url_path->parts};
% unless ($pc) {
  <a href="<%= $url_path %>" class="chip grey-text grey lighten-4"><%= лок 'root' %></a>
% }
% my $con;
% for my $part (@{$url_path->parts}) {
%   $con .="/$part";
  <a href="<%= $con %>" class="chip maroon-text maroon lighten-5"><%= $part %></a>
% }

% if ($pc gt 1 || $c->plugin->config->{'root_url'} ne $url_path->to_route) {
  <a href="<%= $url_path->to_dir %>" class="btn-flat ">
    <svg class="icon icon15 maroon-fill"><use xlink:href="#svg:up-left-round" />
    <span class="maroon-text"><%= лок 'Up'%></span>
  </a>
% }

</h1>
<hr />

@@ Mojolicious-Plugin-StaticShare/markdown.html.ep
% layout 'Mojolicious-Plugin-StaticShare/main';
%= include 'Mojolicious-Plugin-StaticShare/header';
<%== stash('markdown') || stash('content') || 'none content' %>

@@ Mojolicious-Plugin-StaticShare/not_found.html.ep
% layout 'Mojolicious-Plugin-StaticShare/main';
<h1 class="red-text">404</h1>
<hr />
<h2><%= лок 'Not found'%>
%#<span class="chip maroon-text maroon lighten-5" ><%= $url_path || лок 'root path' %></span>
% my $con;
% for my $part (@{$url_path->parts}) {
%   $con .="/$part";
  <a href="<%= $con %>" class="chip maroon-text maroon lighten-5"><%= $part %></a>
% }

% if (@{$url_path->parts}) {
  <a href="<%= $url_path->to_dir %>" class="btn-flat dir maroon-text"><svg class="icon icon15 maroon-fill"><use xlink:href="#svg:up-left-round" /></svg> <%= лок 'Up'%></a>
% }

</h2>

@@ Mojolicious-Plugin-StaticShare/exception.html.ep
% layout 'Mojolicious-Plugin-StaticShare/main';
% title лок 'Error';
<h1 class="red-text text-darken-2 bold">500</h1>
<hr />

<h2><%= лок 'Error on path'%>
% my $con;
% for my $part (@{$url_path->parts}) {
%   $con .="/$part";
  <a href="<%= $con %>" class="chip maroon-text maroon lighten-5"><%= $part %></a>
% }

% if (@{$url_path->parts}) {
  <a href="<%= $url_path->to_dir %>" class="btn-flat dir maroon-text"><svg class="icon icon15 maroon-fill fill-darken-1"><use xlink:href="#svg:up-left-round" /></svg> <%= лок 'Up'%></a>
% }

</h2>

% if(my $msg = $exception && $exception->message) {
%   utf8::decode($msg);
    <h3 id="error" style="white-space:pre;" class="red-text"><%= $msg %></h3>
% }



@@ Mojolicious-Plugin-StaticShare/svg.html.ep

<svg xmlns="http://www.w3.org/2000/svg" style="display: none;">
  
  <symbol id="svg:up-left-round" viewBox="0 0 50 50">
    <path style=" " d="M 43.652344 50.003906 C 40.652344 50.003906 14.632813 49.210938 14.011719 22 L 3.59375 22 L 20 0.34375 L 36.410156 22 L 26.011719 22 C 26.472656 46.441406 43.894531 47.988281 44.074219 48.003906 L 44.035156 50 C 44.035156 50 43.902344 50.003906 43.652344 50.003906 Z "></path>
  </symbol>
  
  <symbol id="svg:add-file" viewBox="0 0 26 26">
    <path style=" " d="M 3 0 C 1.34375 0 0 1.34375 0 3 L 0 20 C 0 21.65625 1.34375 23 3 23 L 12.78125 23 C 12.519531 22.371094 12.339844 21.699219 12.25 21 L 3 21 C 2.449219 21 2 20.550781 2 20 L 2 3 C 2 2.449219 2.449219 2 3 2 L 21 2 C 21.550781 2 22 2.449219 22 3 L 22 12.46875 C 22.710938 12.65625 23.382813 12.945313 24 13.3125 L 24 3 C 24 1.34375 22.65625 0 21 0 Z M 5 5 C 4.449219 5 4 5.449219 4 6 L 4 7 C 4 7.550781 4.449219 8 5 8 L 6 8 C 6.550781 8 7 7.550781 7 7 L 7 6 C 7 5.449219 6.550781 5 6 5 Z M 10 5.0625 C 9.449219 5.0625 9 5.511719 9 6.0625 L 9 7.0625 C 9 7.613281 9.449219 8.0625 10 8.0625 L 19 8.0625 C 19.550781 8.0625 20 7.613281 20 7.0625 L 20 6.0625 C 20 5.511719 19.550781 5.0625 19 5.0625 Z M 5 10.0625 C 4.449219 10.0625 4 10.511719 4 11.0625 L 4 12.0625 C 4 12.613281 4.449219 13.0625 5 13.0625 L 6 13.0625 C 6.550781 13.0625 7 12.613281 7 12.0625 L 7 11.0625 C 7 10.511719 6.550781 10.0625 6 10.0625 Z M 10 10.0625 C 9.449219 10.0625 9 10.511719 9 11.0625 L 9 12.0625 C 9 12.613281 9.449219 13.0625 10 13.0625 L 16.4375 13.0625 C 17.5 12.511719 18.6875 12.191406 19.96875 12.1875 C 19.972656 12.144531 20 12.109375 20 12.0625 L 20 11.0625 C 20 10.511719 19.550781 10.0625 19 10.0625 Z M 20 14.1875 C 16.789063 14.1875 14.1875 16.789063 14.1875 20 C 14.1875 23.210938 16.789063 25.8125 20 25.8125 C 23.210938 25.8125 25.8125 23.210938 25.8125 20 C 25.8125 16.789063 23.210938 14.1875 20 14.1875 Z M 5 15.0625 C 4.449219 15.0625 4 15.511719 4 16.0625 L 4 17.0625 C 4 17.613281 4.449219 18.0625 5 18.0625 L 6 18.0625 C 6.550781 18.0625 7 17.613281 7 17.0625 L 7 16.0625 C 7 15.511719 6.550781 15.0625 6 15.0625 Z M 10 15.0625 C 9.449219 15.0625 9 15.511719 9 16.0625 L 9 17.0625 C 9 17.613281 9.449219 18.0625 10 18.0625 L 12.4375 18.0625 C 12.722656 16.949219 13.230469 15.925781 13.9375 15.0625 Z M 19 17 L 21 17 L 21 19 L 23 19 L 23 21 L 21 21 L 21 23 L 19 23 L 19 21 L 17 21 L 17 19 L 19 19 Z "></path>
  </symbol>
  
  <symbol id="svg:download" viewBox="0 0 26 26">
    <path style=" " d="M 11 0 C 9.34375 0 8 1.34375 8 3 L 8 11 L 4.75 11 C 3.339844 11 3.042969 11.226563 4.25 12.4375 L 10.84375 19.03125 C 13.042969 21.230469 13.015625 21.238281 15.21875 19.03125 L 21.78125 12.4375 C 22.988281 11.226563 22.585938 11 21.3125 11 L 18 11 L 18 3 C 18 1.34375 16.65625 0 15 0 Z M 0 19 L 0 23 C 0 24.65625 1.34375 26 3 26 L 23 26 C 24.65625 26 26 24.65625 26 23 L 26 19 L 24 19 L 24 23 C 24 23.550781 23.550781 24 23 24 L 3 24 C 2.449219 24 2 23.550781 2 23 L 2 19 Z "></path>
  </symbol>
  
  <symbol id="svg:upload" viewBox="0 0 26 26">
    <path style=" " d="M 12.96875 0.3125 C 12.425781 0.3125 11.882813 0.867188 10.78125 1.96875 L 4.21875 8.5625 C 3.011719 9.773438 3.414063 10 4.6875 10 L 8 10 L 8 18 C 8 19.65625 9.34375 21 11 21 L 15 21 C 16.65625 21 18 19.65625 18 18 L 18 10 L 21.25 10 C 22.660156 10 22.957031 9.773438 21.75 8.5625 L 15.15625 1.96875 C 14.054688 0.867188 13.511719 0.3125 12.96875 0.3125 Z M 0 19 L 0 23 C 0 24.65625 1.34375 26 3 26 L 23 26 C 24.65625 26 26 24.65625 26 23 L 26 19 L 24 19 L 24 23 C 24 23.550781 23.550781 24 23 24 L 3 24 C 2.449219 24 2 23.550781 2 23 L 2 19 Z "></path>
  </symbol>
  
  <symbol id="svg:folder" viewBox="0 0 30 30">
    <path d="M 4 3 C 2.895 3 2 3.895 2 5 L 2 8 L 13 8 L 28 8 L 28 7 C 28 5.895 27.105 5 26 5 L 11.199219 5 L 10.582031 3.9707031 C 10.221031 3.3687031 9.5701875 3 8.8671875 3 L 4 3 z M 3 10 C 2.448 10 2 10.448 2 11 L 2 23 C 2 24.105 2.895 25 4 25 L 26 25 C 27.105 25 28 24.105 28 23 L 28 11 C 28 10.448 27.552 10 27 10 L 3 10 z"></path>
  </symbol>
  
</svg>
