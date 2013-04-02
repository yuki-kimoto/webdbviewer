package Mojolicious::Plugin::DBViewer::SQLite::Command;
use Mojo::Base 'Mojolicious::Plugin::DBViewer::Command';

has 'dbi';

sub current_database { 'main' }

sub show_primary_key {
  my ($self, $database, $table) = @_;
  my $show_create_table = $self->show_create_table($database, $table) || '';
  
  my @primary_keys = $self->dbi->dbh->primary_key(undef, $database, $table);
  my $primary_key = '(' . join(', ', @primary_keys) . ')';

  return $primary_key;
}

sub show_null_allowed_column {
  my ($self, $database, $table) = @_;
  
  my $sql = "pragma table_info($table)";
  my $rows = $self->dbi->execute($sql)->all;
  my $null_allowed_column = [];
  for my $row (@$rows) {
    push @$null_allowed_column, $row->{name} if !$row->{notnull};
  }
  return $null_allowed_column;
}

sub show_database_engines {
  my ($self, $database) = @_;
  
  my $tables = $self->show_tables($database);
  my $database_engines = {};
  for my $table (@$tables) {
    my $database_engine = $self->show_database_engine($database, $table);
    $database_engines->{$table} = $database_engine;
  }
  
  return $database_engines;
}

sub show_database_engine {
  my ($self, $database, $table) = @_;
  
  my $show_create_table = $self->show_create_table($database, $table) || '';
  my $database_engine = '';
  if ($show_create_table =~ /ENGINE=(.+?)(\s+|$)/i) {
    $database_engine = $1;
  }
  
  return $database_engine;
}

sub show_databases { ['main'] }

sub show_tables { 
  my ($self, $database) = @_;

  my $sql = <<"EOS";
select distinct(name)
  from $database.sqlite_master
  where type in ('table', 'view')
  order by name;
EOS

  my $tables = $self->dbi->execute($sql)->values;
  
  return $tables;
}

sub show_create_table {
  my ($self, $database, $table) = @_;
  
  my $sql = <<"EOS";
select sql
  from $database.sqlite_master
  where type in ('table', 'type') and name = '$table'
EOS
  
  my $create_table = $self->dbi->execute($sql)->value;
  
  # Format
  $create_table =~ s/\(/(\n  /;
  $create_table =~ s/, /,\n  /g;
  $create_table =~ s/\)$/\n)/;
  
  return $create_table;
}

1;
