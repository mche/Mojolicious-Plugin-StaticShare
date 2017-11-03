package Mojolicious::Plugin::StaticShare::Static;
use utf8;
=pod

=head1 Concatenate files js+css into package __DATA__

  > (
    cat lib/Mojolicious/Plugin/StaticShare/Static.orig.pm ;
    echo "@@ Mojolicious-Plugin-StaticShare.css"; cat files/css/main.css;
    echo "@@ Mojolicious-Plugin-StaticShare.js"; cat files/js/main.js
  ) > lib/Mojolicious/Plugin/StaticShare/Static.pm

=cut
1;
__DATA__
@@ main.css.map
"names": [],
"file": "main.css"

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


%# Материализные стили внутри main.css после слияния: sass --watch sass:css
%#= stylesheet '/css/main.css'
<link href="/Mojolicious-Plugin-StaticShare.css" rel="stylesheet">


<meta name="app:name" content="<%= stash('app:name') // 'Mojolicious::Plugin::StaticShare' %>">
<meta name="app:version" content="<%= stash('app:version') // 0.01 %>">

</head>
<body class="white">

%= include 'Mojolicious-Plugin-StaticShare/svg';

<header><div class="header clearfix"><%= stash('header-content')   %></div></header>
<main><div class="container clearfix"><%= stash('content') || content %></div></main>

%#= javascript '/js/main.js'
<script src="/mojo/jquery/jquery.js"></script>

<script src="/Mojolicious-Plugin-StaticShare.js"></script>
%= javascript begin

$( document ).ready(function() {
  // console.log('Всем привет!');
  $("#drop-file-div").dmUploader({
    "url": '<%= $url_path %>',
    "onComplete": function(){
      //console.log('We reach the end of the upload Queue!');
      document.location.reload();
    }
  });
});

% end

</body>
</html>

@@ Mojolicious-Plugin-StaticShare/en/dir.html.ep
% layout 'Mojolicious-Plugin-StaticShare/main';

<h1><%= лок 'Index of'%>
%#<span class="chip maroon-text maroon lighten-5" ><%= $url_path || 'root path' %></span>
% my $con;
% for my $part (@{$url_path->parts}) {
%   $con .="/$part";
  <a href="<%= $con %>" class="chip maroon-text maroon lighten-5"><%= $part %></a>

% }

</h1>
<hr />

<div class="row">

<div class="col s6">

<h2><%= лок 'Dirs'%> <span class="chip blue-text blue lighten-5" style="font-size: 0.8rem;"><%= scalar @$dirs %></span>
% if (@{$url_path->parts}) {
  <a href="<%= $url_path->to_dir %>" class="btn-flat dir bold right"><svg class="icon icon15 light-blue-fill fill-darken-1"><use xlink:href="#up-left-round" /></svg> <%= лок 'Up'%></a>
% }
</h2>

<ul class="collection">
  % for my $dir (sort  @$dirs) {
    <li class="collection-item dir"><a href='<%= $url_path.'/'.$dir %>'><%== $dir %></a></li>
  % }
</ul>

</div>

<div class="col s6">
<h2>
  <%= лок 'Files'%>
  <span class="chip blue-text blue lighten-5" style="font-size: 0.8rem;"><%= scalar @$files %></span>
  <a id="add-file-btn" href="javascript:" class="btn-flat right ">
    <svg class="icon icon15 light-blue-fill fill-darken-1"><use xlink:href="#add-file" /></svg>
    <span><%= лок 'Add file'%></span>
  </a>
</h2>

<div id="drop-file-div">
  Drag and Drop Files Here<br />
  or click to add files using the input<br />
  <input type="file" name="files[]" multiple="multiple" title="Click to add Files">
</div>

<table class="striped">
  <tr>
    <th class="name"><%= лок 'Name'%></th>
    <th class="size center"><%= лок 'Size'%></th>
    <!--th class="type">Type</th-->
    <th class="mtime center"><%= лок 'Last Modified'%></th>
  </tr>
  % for my $file (sort { $a->{name} cmp $b->{name} } @$files) {
  <tr>
    <td class="name"><a href="<%= $url_path.'/'.$file->{name} %>"><%== $file->{name} %></a></td>
    <td class="size right-align"><%= $file->{size} %></td>
    <!--td class="type"><%= $file->{type} %></td-->
    <td class="mtime right-align"><%= $file->{mtime} %></td>
  </tr>
  % }
</table>

@@ Mojolicious-Plugin-StaticShare/markdown.html.ep
% layout 'Mojolicious-Plugin-StaticShare/main';

@@ Mojolicious-Plugin-StaticShare/not_found.html.ep
% layout 'Mojolicious-Plugin-StaticShare/main';
<h1 class="red-text">404</h1>
<h2><%= лок 'Not found'%> <span class="chip maroon-text maroon lighten-5" ><%= $url_path || 'root path' %></span></h2>

@@ Mojolicious-Plugin-StaticShare/exception.html.ep
% layout 'Mojolicious-Plugin-StaticShare/main';
<h1 class="red-text">500</h1>
<h2><%= лок 'Disabled index of'%> <span class="chip maroon-text maroon lighten-5" ><%= $url_path || 'root path' %></span></h2>

@@ Mojolicious-Plugin-StaticShare/svg.html.ep

<svg xmlns="http://www.w3.org/2000/svg" style="display: none;">
  
  <symbol id="up-left-round" viewBox="0 0 50 50">
    <path style=" " d="M 43.652344 50.003906 C 40.652344 50.003906 14.632813 49.210938 14.011719 22 L 3.59375 22 L 20 0.34375 L 36.410156 22 L 26.011719 22 C 26.472656 46.441406 43.894531 47.988281 44.074219 48.003906 L 44.035156 50 C 44.035156 50 43.902344 50.003906 43.652344 50.003906 Z "></path>
  </symbol>
  
  <symbol id="add-file" viewBox="0 0 26 26">
    <path style=" " d="M 3 0 C 1.34375 0 0 1.34375 0 3 L 0 20 C 0 21.65625 1.34375 23 3 23 L 12.78125 23 C 12.519531 22.371094 12.339844 21.699219 12.25 21 L 3 21 C 2.449219 21 2 20.550781 2 20 L 2 3 C 2 2.449219 2.449219 2 3 2 L 21 2 C 21.550781 2 22 2.449219 22 3 L 22 12.46875 C 22.710938 12.65625 23.382813 12.945313 24 13.3125 L 24 3 C 24 1.34375 22.65625 0 21 0 Z M 5 5 C 4.449219 5 4 5.449219 4 6 L 4 7 C 4 7.550781 4.449219 8 5 8 L 6 8 C 6.550781 8 7 7.550781 7 7 L 7 6 C 7 5.449219 6.550781 5 6 5 Z M 10 5.0625 C 9.449219 5.0625 9 5.511719 9 6.0625 L 9 7.0625 C 9 7.613281 9.449219 8.0625 10 8.0625 L 19 8.0625 C 19.550781 8.0625 20 7.613281 20 7.0625 L 20 6.0625 C 20 5.511719 19.550781 5.0625 19 5.0625 Z M 5 10.0625 C 4.449219 10.0625 4 10.511719 4 11.0625 L 4 12.0625 C 4 12.613281 4.449219 13.0625 5 13.0625 L 6 13.0625 C 6.550781 13.0625 7 12.613281 7 12.0625 L 7 11.0625 C 7 10.511719 6.550781 10.0625 6 10.0625 Z M 10 10.0625 C 9.449219 10.0625 9 10.511719 9 11.0625 L 9 12.0625 C 9 12.613281 9.449219 13.0625 10 13.0625 L 16.4375 13.0625 C 17.5 12.511719 18.6875 12.191406 19.96875 12.1875 C 19.972656 12.144531 20 12.109375 20 12.0625 L 20 11.0625 C 20 10.511719 19.550781 10.0625 19 10.0625 Z M 20 14.1875 C 16.789063 14.1875 14.1875 16.789063 14.1875 20 C 14.1875 23.210938 16.789063 25.8125 20 25.8125 C 23.210938 25.8125 25.8125 23.210938 25.8125 20 C 25.8125 16.789063 23.210938 14.1875 20 14.1875 Z M 5 15.0625 C 4.449219 15.0625 4 15.511719 4 16.0625 L 4 17.0625 C 4 17.613281 4.449219 18.0625 5 18.0625 L 6 18.0625 C 6.550781 18.0625 7 17.613281 7 17.0625 L 7 16.0625 C 7 15.511719 6.550781 15.0625 6 15.0625 Z M 10 15.0625 C 9.449219 15.0625 9 15.511719 9 16.0625 L 9 17.0625 C 9 17.613281 9.449219 18.0625 10 18.0625 L 12.4375 18.0625 C 12.722656 16.949219 13.230469 15.925781 13.9375 15.0625 Z M 19 17 L 21 17 L 21 19 L 23 19 L 23 21 L 21 21 L 21 23 L 19 23 L 19 21 L 17 21 L 17 19 L 19 19 Z "></path>
  </symbol>
  
</svg>

