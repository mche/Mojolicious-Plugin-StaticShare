package Mojolicious::Plugin::StaticShare;
use Mojo::Base 'Mojolicious::Plugin';

our $VERSION = '0.01';

sub register {
  my ($self, $app, $args) = @_;
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

=head2 Public interfaces

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
