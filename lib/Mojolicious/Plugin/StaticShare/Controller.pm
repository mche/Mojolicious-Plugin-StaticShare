package Mojolicious::Plugin::StaticShare::Controller;
use Mojo::Base 'Mojolicious::Controller';
use HTTP::AcceptLanguage;
use Mojo::Path;
use Mojo::File qw(path);
use Mojo::Util qw ( decode encode url_unescape xml_escape);#encode 
use Time::Piece;# module replaces the standard localtime and gmtime functions with implementations that return objects
use Mojo::Asset::File;

has qw(plugin);
has public_uploads => sub { !! shift->plugin->config->{public_uploads} };
has admin => sub {
  my $c = shift;
  return 
    unless my $pass = $c->plugin->config->{admin_pass};
  my $sess = $c->session;
  $sess->{StaticShare}{admin} = 1
    if $c->param('admin') && $c->param('admin') eq $pass;
  return $sess->{StaticShare} && $sess->{StaticShare}{admin};
};

sub get {
  my ($c) = @_;
  
  $c->_stash();
  
  return $c->not_found
    if !$c->admin && grep {/^\./} @{$c->stash('url_path')->parts};
  
  my $file_path = path(url_unescape($c->stash('file_path')));
  
  return $c->dir($file_path)
    if -d $file_path;
  return $c->file($file_path)
    if -f $file_path;

  $c->not_found;
}

sub post {
  my ($c) = @_;
  $c->_stash();
  
  my $file_path = path(url_unescape($c->stash('file_path')));
  
  if ($c->admin && (my $dir = $c->param('dir'))) {
    return $c->new_dir($file_path, $dir);
  }
  
  
  return $c->render(json=>{error=>$c->лок('target directory not found')})
    if grep {/^\./} @{$c->stash('url_path')->parts};
  
  return $c->render(json=>{error=>$c->лок('you cant upload')})
    unless $c->admin || $c->public_uploads;
  
  
  return $c->render(json=>{error=>$c->лок('Cant open target directory')})
    unless -w $file_path;
  #~ $c->req->max_message_size(0);
  # Check file size
  return $c->render(json=>{error=>$c->лок('file is too big')}, status=>417)
    if $c->req->is_limit_exceeded;

  my $file = $c->req->upload('file');
  my $name = url_unescape($c->param('name') || $file->filename);
  my $to = $file_path->child(encode('UTF-8', $name));
  
  return $c->render(json=>{error=>$c->лок('path is not a directory')})
    unless -d $file_path;
  return $c->render(json=>{error=>$c->лок('file already exists')})
    if -e $to;
  
  $file->asset->move_to($to);
  
  $c->render(json=>{ok=> $c->stash('url_path')->merge($name)->to_route});
}

sub _stash {
  my ($c) = @_;
  $c->plugin($c->stash('plugin'));
  my $lang = HTTP::AcceptLanguage->new($c->req->headers->accept_language || 'en;q=0.5');
  $c->stash('language' => $lang);
  $c->stash('title' => $c->лок('Share'));
  my $pth = Mojo::Path->new($c->stash('pth'))->leading_slash(0)->trailing_slash(0);
  $pth = $pth->trailing_slash(1)->merge('.'.$c->stash('format'))
    if $c->stash('format');
  $c->stash('pth' => $pth);
  my $url_path = $c->plugin->root_url->clone->merge($c->stash('pth'))->trailing_slash(1);
  $c->stash('url_path' => $url_path);
  $c->stash('file_path' => $c->plugin->root_dir->clone->merge($c->stash('pth')));
}


sub dir {
  my ($c, $path) = @_;
  
  my $ex = Mojo::Exception->new($c->лок(qq{Cant open directory}));
  opendir(my $dir, $path)
    or return $c->render_maybe('Mojolicious-Plugin-StaticShare/exception', status=>500, exception=>$ex)
      || $c->reply->exception($ex);
  
  my $files = $c->stash('files' => [])->stash('files');
  my $dirs = $c->stash('dirs' => [])->stash('dirs');
  
  while (readdir $dir) {
    next
      if $_ eq '.' || $_ eq '..';
    next
      if !$c->admin && /^\./;
    
    my $child = $path->child($_);
    
    push @$dirs, decode('UTF-8', $_)
      and next
      if -d $child && -r _;
    
    next
      unless -f _;
    
    my @stat = stat $child;
    
    push @$files, {
      name  => decode('UTF-8', $_),
      size  => $stat[7] || 0,
      #~ type  => $c->plugin->mime->type(  (/\.([0-9a-zA-Z]+)$/)[0] || 'txt' ) || 'application/octet-stream',
      mtime => decode('UTF-8', localtime( $stat[9] )->strftime), #->to_datetime, #to_string(),
      #~ mode=> $stat[2] & 07777, #-r _,
    };
  }
  closedir $dir;
  
  for my $index ($c->plugin->config->{dir_index} ? @{$c->plugin->config->{dir_index}} : ()) {
    my $file = $path->child($index);
    next
      unless -f $file;
    
    $c->_stash_markdown($file)
      and $c->stash(index=>$index)
      and last
      if $index =~ $c->plugin->is_markdown;
    
    $c->_stash_pod($file)
      and $c->stash(index=>$index)
      and last
      if $index =~ $c->plugin->is_pod;

  }
  
  return $c->render(ref $c->plugin->config->{render_dir} ? %{$c->plugin->config->{render_dir}} : $c->plugin->config->{render_dir},)
    if $c->plugin->config->{render_dir}; 
  
  unless (defined($c->plugin->config->{render_dir}) && $c->plugin->config->{render_dir} eq 0) {
    $c->render_maybe("Mojolicious-Plugin-StaticShare/$_/dir", format=>'html', handler=>'ep',)
      and return
      for $c->stash('language')->languages;
    
    return $c->render('Mojolicious-Plugin-StaticShare/en/dir', format=>'html', handler=>'ep',);
  }
  
  $c->render_maybe('Mojolicious-Plugin-StaticShare/exception', status=>500,exception=>Mojo::Exception->new(qq{Template rendering for dir content not found}))
    or $c->reply->exception();
}

sub new_dir {
  my ($c, $path, $dir) = @_;
  
  my $to = $path->child(encode('UTF-8', url_unescape($dir)));
  
  return $c->render(json=>{error=>$c->лок('dir or file exists')})
    if -e $to;
  
  $to->make_path;
  
  $c->render(json=>{ok=> $c->stash('url_path')->clone->merge($dir)->trailing_slash(1)->to_route});
  
}

sub file {
  my ($c, $path) = @_;
  
  my $ex = Mojo::Exception->new($c->лок(qq{Permission denied}));
  return $c->render_maybe('Mojolicious-Plugin-StaticShare/exception', status=>500,exception=>$ex)
    || $c->reply->exception($ex)
    unless -r $path;
  
  my $filename = $path->basename;
  
  $c->_markdown($path)
    and return
    unless ($c->plugin->config->{render_markdown} || '') eq 0 || $c->param('attachment') || $filename !~ $c->plugin->is_markdown;
  
  $c->_pod($path)
    and return
    unless ($c->plugin->config->{render_pod} || '') eq 0 || $c->param('attachment') || $filename !~ $c->plugin->is_pod;
  
  $c->res->headers->content_disposition($c->param('attachment') ? "attachment; filename=$filename;" : "inline");
  my $type  =$c->plugin->mime->type(  ( $path =~ /\.([0-9a-zA-Z]+)$/)[0] || 'txt' ) || $c->plugin->mime->type('txt');#'application/octet-stream';
  $c->res->headers->content_type($type);
  $c->reply->asset(Mojo::Asset::File->new(path => $path));
  
}

sub _markdown {# file
  my ($c, $path) = @_;

  my $ex = Mojo::Exception->new($c->лок(qq{Please install or verify markdown module (default to Text::Markdown::Hoedown) with markdown(\$str) sub or parse(\$str) method}));

  $c->_stash_markdown($path)
    or return $c->render_maybe('Mojolicious-Plugin-StaticShare/exception', status=>500,exception=>$ex)
        || $c->reply->exception($ex);
  
  return $c->plugin->config->{render_markdown}
    ? $c->render(ref $c->plugin->config->{render_markdown} ? %{$c->plugin->config->{render_markdown}} : $c->plugin->config->{render_markdown},)
    : $c->render('Mojolicious-Plugin-StaticShare/markdown', format=>'html', handler=>'ep',);
  
}

my $layout_re = qr|^(?:\s*%+\s*layouts/(.+)[;\s]+)|;

sub _stash_markdown {
  my ($c, $path) = @_;
  my $md = $c->plugin->markdown
    or return; # not installed
  my $content = decode('UTF-8', $path->slurp);
  $content =~ s|$layout_re|$c->_layout_index($1)|e;#) {# || $content =~ s/(?:%\s*layout\s+"([^"]+)";?)//m
  my $dom = Mojo::DOM->new($md->parse($content));
  $dom->find('script')->each(\&_sanitize_script);
  $dom->find('*')->each(\&_dom_attrs);
  $c->stash(markdown => $dom->at('body') || $dom);
  
}

my $layout_ext_re = qr|\.([^/\.;\s]+)?\.?([^/\.;\s]+)?$|; # .html.ep

sub _layout_index {# from regexp execute
  my ($c, @match) = @_;#
  $match[0] =~ s|[;\s]+$||;
  push @match, $1, $2
    if $match[0] =~ s|$layout_ext_re||;
  my $found = $c->app->renderer->template_path({
      template => "layouts/$match[0]",
      format   => $match[1] || 'html',
      handler  => $match[2] || 'ep',
    });
  $c->layout(encode('UTF-8', $match[0]))
    and return
    if $found;
  return "<span style='color:red;'> layout [$match[0]].$match[1].$match[2] not found</span>";
}

sub _sanitize_script {# for markdown
  my $el = shift;
  my $text = xml_escape $el->text;
  $el->replace("<code class=script>$text</code>");
}

sub _dom_attrs {# for markdown
# translate ^{...} to id, style, class attributes
# берем только первый child и он должен быть текстом
  my $el = shift;
  my $text = $el->text
    or return;
  my $child1 = $el->child_nodes->first;
  my $parent = $child1->parent;
  return
    unless $parent && $parent->type eq 'tag' && $child1->type eq 'text';
  my $content = $child1->content;
  if ($content =~ s|^(?:\s*\{([^\}]+)\}\s*)||) {
    my $attrs = $1;
    while ($attrs =~ s|([\w\-]+\s*:\s*[^;]+;)|| ) {# styles
      #~ warn "\tstyle=", $1;
      $parent->{style} .= " $1";
    }
    while ($attrs =~ s|\.?([.\w\-]+)||) {# classes
      #~ warn "\tclass=", $1;
      $parent->{class} .= " $1";
    }
    while ($attrs =~ s|#([\w\-]+)||) {# id
      #~ warn "\tid=", $1;
      $parent->{id}  = $1;
    }
    $child1->content($content);# replace
  }
}

sub _pod {# file
  my ($c, $path) = @_;

  $c->_stash_pod($path)
    or return;# $c->render_maybe('Mojolicious-Plugin-StaticShare/exception', status=>500,exception=>$ex)
        #~ || $c->reply->exception($ex);
  
  return $c->plugin->config->{render_pod}
    ? $c->render(ref $c->plugin->config->{render_pod} ? %{$c->plugin->config->{render_pod}} : $c->plugin->config->{render_pod},)
    : $c->render('Mojolicious-Plugin-StaticShare/pod', format=>'html', handler=>'ep',);
  
}

sub _stash_pod {
  my ($c, $path) = @_;
  return
    unless $c->app->renderer->helpers->{'pod_to_html'};

  my $content = decode('UTF-8', $path->slurp);
  $content =~ s|$layout_re|$c->_layout_index($1)|e;#) {# || $content =~ s/(?:%\s*layout\s+"([^"]+)";?)//m
  my $dom = Mojo::DOM->new($c->pod_to_html($content));
  $dom->find('script')->each(\&_sanitize_script);
  $dom->find('*')->each(\&_dom_attrs);
  $c->stash(pod =>  $dom->at('body') || $dom);
}

sub not_found {
  my $c = shift;
  $c->render_maybe('Mojolicious-Plugin-StaticShare/not_found', format=>'html', handler=>'ep', status=>404,)
    or $c->reply->not_found;
  
};

1;