use 5.008001;
package Mojolicious::Plugin::DBViewer;
use Mojo::Base 'Mojolicious::Plugin';

use Cwd 'abs_path';
use DBIx::Custom;
use Validator::Custom;
use Carp 'croak';

our $VERSION = '0.26';

has 'command';
has 'prefix';
has 'validator';
has 'dbi';

sub _driver { lc shift->dbi->dbh->{Driver}->{Name} }

sub register {
  my ($self, $app, $conf) = @_;
  
  # Prefix
  my $prefix = $conf->{prefix};
  $prefix = 'dbviewer' unless defined $prefix;
  
  # Slash and prefix
  my $sprefix = $prefix eq '' ? $prefix : "/$prefix";
  
  # Default charset
  my $charset = $conf->{charset} || 'UTF-8';
  
  # DBI
  my $dbi = DBIx::Custom->connect(
    dsn => $conf->{dsn},
    user => $conf->{user},
    password => $conf->{password},
    option => $conf->{option} || {},
    connector => 1
  );
  $self->dbi($dbi);
  if (ref $conf->{connector_get} eq 'SCALAR') {
    ${$conf->{connector_get}} = $dbi->connector;
  }
  
  # Validator
  my $validator = Validator::Custom->new;
  $validator->register_constraint(
    safety_name => sub {
      my $name = shift;
      return ($name || '') =~ /^[a-zA-Z0-9_\.]+$/ ? 1 : 0;
    }
  );
  $self->validator($validator);
  
  # Commaned and namespace
  my $driver = $self->_driver;
  my $command;
  my $namespace;
  if ($driver eq 'mysql') {
    require Mojolicious::Plugin::DBViewer::MySQL::Command;
    $command = Mojolicious::Plugin::DBViewer::MySQL::Command->new(dbi => $dbi);
    $namespace = 'Mojolicious::Plugin::DBViewer::MySQL';
  }
  elsif ($driver eq 'sqlite') {
    require Mojolicious::Plugin::DBViewer::SQLite::Command;
    $command = Mojolicious::Plugin::DBViewer::SQLite::Command->new(dbi => $dbi);
    $namespace = 'Mojolicious::Plugin::DBViewer::SQLite';
  }
  else { croak "Mojolicious::Plugin::DBViewer don't support $driver" }
  $self->command($command);
  
  # Add public and template path
  my $class = __PACKAGE__;
  $class =~ s/::/\//g;
  $class .= '.pm';
  my $base_path = abs_path $INC{$class};
  $base_path =~ s/\.pm$//;
  push @{$app->static->paths}, "$base_path/public";
  push @{$app->renderer->paths}, "$base_path/templates";
  
  # Routes
  my $r = $conf->{route};
  $r = $app->routes unless defined $r;
  $self->prefix($prefix);
  {
    # Config
    my $site_title = $conf->{site_title} || 'DBViewer';
    my $footer_text = $conf->{footer_text} || 'Mojolicious::Plugin::DBViewer';
    my $footer_link = $conf->{footer_link}
      || 'http://search.cpan.org/dist/Mojolicious-Plugin-DBViewer'
       . '/lib/Mojolicious/Plugin/DBViewer.pm';

    # Utilities
    my $utilities = [
      {path => 'create-tables', title => 'Create tables'},
      {path => 'primary-keys', title => 'Primary keys'},
      {path => 'null-allowed-columns', title => 'Null allowed columns'},
    ];
    if ($driver eq 'mysql') {
      push @$utilities,
        {path => 'database-engines', title => 'Database engines'},
        {path => 'charsets', title => 'Charsets'}
    }
    push @$utilities,
      {path => 'select-statements', title => 'Selects statements'};
    
    # Route Config
    my $r = $r->route("/$prefix")->to(
      'dbviewer#',
      namespace => $namespace,
      plugin => $self,
      sprefix => $sprefix,
      site_title => $site_title,
      driver => $driver,
      dbviewer => $self,
      charset => $charset,
      footer_text => $footer_text,
      footer_link => $footer_link,
      utilities => $utilities,
      join => $conf->{join} || {}
    );
    
    # Auto Route
    $app->plugin('AutoRoute', route => $r, top_dir => 'dbviewer/auto');
  }
}

1;

=head1 NAME

Mojolicious::Plugin::DBViewer - Mojolicious plugin to display database information on browser

=head1 SYNOPSYS

  # Mojolicious::Lite
  plugin(
    'DBViewer',
    dsn => "dbi:mysql:database=bookshop",
    user => 'ken',
    password => '!LFKD%$&'
  );

  # Mojolicious
  $app->plugin(
    'DBViewer',
    dsn => "dbi:mysql:database=bookshop",
    user => 'ken',
    password => '!LFKD%$&'
  );
  
  # Access
  http://localhost:3000/dbviewer
  
  # Prefix change (http://localhost:3000/dbviewer2)
  plugin 'DBViewer', dsn => $dsn, prefix => 'dbviewer2';

  # Route
  my $bridge = $app->route->under(sub {...});
  plugin 'DBViewer', dsn => $dsn, route => $bridge;

=head1 DESCRIPTION

L<Mojolicious::Plugin::DBViewer> is L<Mojolicious> plugin
to display Database information on your browser.

L<Mojolicious::Plugin::DBViewer> have the following features.

=over 4

=item *

Support C<MySQL> and C<SQLite>

=item *

Display all table names

=item *

Display C<show create table>

=item *

Execute simple select statement

=item *

Display C<primary keys>, C<null allowed columnes>, C<database engines>
and C<charsets> in all tables.

=back

=head1 OPTIONS

=head2 connector_get

  connector_get => \$connector

Get L<DBIx::Connector> object internally used.
  
  # Get database handle
  my $connector;
  plugin('DBViewer', ..., connector_get => \$connector);
  my $dbh = $connector->dbh;

=head2 charset

  charset => 'euc-jp'

Database charset, default is C<UTF-8>.

=head2 dsn

  dsn => "dbi:SQLite:dbname=proj"

Datasource name.


=head2 password

  password => 'secret';

Database password.

=head2 prefix

  prefix => 'dbviewer2'

Application base path, default to C<dbviewer>.
You can access DB viewer by the following path.

  http://somehost.com/dbviewer2

=head2 footer_text

  footer_text => 'Web DB Viewer'

Footer text.

=head2 footer_link

  footer_link => 'https://github.com/yuki-kimoto/webdbviewer'

Footer link

=head2 join

  join => {
    book => [
      'left join author on book.author_id = author.id',
      'left join title on book.title_id = title.id'
    ]
  }

Join clause. If you set join clause, you can use join mode in select page.

=head2 option

  option => $option
  
DBI option (L<DBI> connect method's fourth argument).

=head2 route

  route => $route

Router for bridge, default to C<$app->routes>.

  my $bridge = $r->under(sub {...});
  plugin 'DBViewer', dsn => $dsn, route => $bridge;

=head2 user

  user => 'kimoto'

=head2 site_title

  site_title => 'Your DB Viewer';

Site title.

Database user.

=head1 BACKWARDS COMPATIBILITY POLICY

If a feature is DEPRECATED, you can know it by DEPRECATED warnings.
DEPRECATED feature is removed after C<five years>,
but if at least one person use the feature and tell me that thing
I extend one year each time he tell me it.

DEPRECATION warnings can be suppressed
by C<MOJOLICIOUS_PLUGIN_DBVIEWER_SUPPRESS_DEPRECATION>
environment variable.

EXPERIMENTAL features will be changed without warnings.

=head1 COPYRIGHT & LICENSE

Copyright 2013 Yuki Kimoto, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
