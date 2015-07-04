use 5.008007;
package Webdbviewer;
use Mojo::Base 'Mojolicious';
use DBIx::Custom;
use Carp 'croak';

our $VERSION = 'v1.2';

sub startup {
  my $self = shift;
  
  eval {
    # Test Config
    if (my $test_conf_file = $ENV{WEBDBVIEWER_TEST_CONF_FILE}) {
      $self->plugin('INIConfig', {file => $test_conf_file})
        if -f $test_conf_file;
    }
    # Production Config
    else {
      # Config
      $self->plugin('INIConfig', {ext => 'conf'});
      
      # My Config(Development)
      my $my_conf_file = $self->home->rel_file('webdbviewer.my.conf');
      $self->plugin('INIConfig', {file => $my_conf_file}) if -f $my_conf_file;
    }
    
    # Server Config
    my $conf = $self->config;
    $conf->{hypnotoad}{listen} ||= ["http://*:10030"];
    my $listen = $conf->{hypnotoad}{listen};
    if ($listen ne '' && ref $listen ne 'ARRAY') {
      $listen = [ split /,/, $listen ];
    }
    $conf->{hypnotoad}{listen} = $listen;
  };
  if ($@) {
    my $error = "Config file load error: $@";
    $self->log->error($error);
    croak $error;
  }
  
  # Database Config
  my $conf = $self->config;
  my $dbtype = $conf->{basic}{dbtype} || '';
  my $dbname = $conf->{basic}{dbname} || '';
  my $user = $conf->{basic}{user};
  my $password = $conf->{basic}{password};
  my $host = $conf->{basic}{host};
  my $port = $conf->{basic}{port};
  my $site_title = $conf->{basic}{site_title} || 'WebDBViewer';
  my $charset = $conf->{basic}{charset} || 'UTF-8';
  
  my $dsn;
  my $dbi_option = {};
  if ($dbtype eq 'sqlite') {
    $dsn = "dbi:SQLite:dbname=$dbname";
  }
  elsif ($dbtype eq 'mysql') {
    $dsn = "dbi:mysql:database=$dbname";
    $dsn .= ";host=$host" if defined $host && length $host;
    $dsn .= ";port=$port" if defined $host && length $host;
    
    my $mysql_read_default_file = $conf->{mysql}{mysql_read_default_file};
    $dsn .= ";mysql_read_default_file=$mysql_read_default_file"
      if defined $mysql_read_default_file && length $mysql_read_default_file;

    # set names
    my $set_names = $conf->{mysql}{set_names};
    if (defined $set_names && length $set_names) {
      $dbi_option->{Callbacks}{connected} = sub {
        my $dbh = shift;
        $dbh->do("set names $set_names");
        return;
      }
    }
  }
  else {
    my $error = "Error in configuration file: [basic]dbtype ($dbtype) is not supported";
    $self->log->error($error);
    croak $error;
  }
  
  # Join
  my $join = {};
  for my $ncolumn (keys %{$conf->{join} || {}}) {
    my $clause = $conf->{join}{$ncolumn};
    if ($ncolumn =~ /(.+)\[\d+\]?/) {
      my $column = $1;
      if (defined $join->{$column}) {
        push @{$join->{$column}}, $clause;
      }
      else {
        $join->{$column} = [$clause];
      }
    }
  }
  $self->config->{_join_normalized} = $join;
  
  # Load DBViewer plugin
  eval {
    $self->plugin(
      'DBViewer',
      dsn => $dsn,
      user => $user,
      password => $password,
      prefix => '',
      site_title => $site_title,
      option => $dbi_option,
      charset => $charset,
      footer_text => 'WebDBViewer',
      footer_link => 'http://perlcodesample.sakura.ne.jp/webdbviewer-site/',
      join => $join
    );
  };
  if ($@) {
    $self->log->error($@);
    croak $@;
  }
  
  # Reverse proxy support
  my $reverse_proxy_on = $self->config->{reverse_proxy}{on};
  my $path_depth = $self->config->{reverse_proxy}{path_depth};
  if ($reverse_proxy_on) {
    $ENV{MOJO_REVERSE_PROXY} = 1;
    if ($path_depth) {
      $self->hook('before_dispatch' => sub {
        my $self = shift;
        for (1 .. $path_depth) {
          my $prefix = shift @{$self->req->url->path->parts};
          push @{$self->req->url->base->path->parts}, $prefix;
        }
      });
    }
  }

}

1;
