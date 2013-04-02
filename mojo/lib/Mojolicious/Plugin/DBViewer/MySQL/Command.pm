package Mojolicious::Plugin::DBViewer::MySQL::Command;
use Mojo::Base 'Mojolicious::Plugin::DBViewer::Command';

sub current_database {
  my $self = shift;
  return $self->dbi->execute('select database()')->fetch->[0];
}

sub show_primary_key {
  my ($self, $database, $table) = @_;
  my $show_create_table = $self->show_create_table($database, $table) || '';
  my $primary_key = '';
  if ($show_create_table =~ /PRIMARY\s+KEY\s+(.+?)\n/i) {
    $primary_key = $1;
    $primary_key =~ s/,$//;
  }
  return $primary_key;
}

sub show_null_allowed_column {
  my ($self, $database, $table) = @_;
  
  my $show_create_table = $self->show_create_table($database, $table) || '';
  my @lines = split(/\n/, $show_create_table);
  my $null_allowed_column = [];
  for my $line (@lines) {
    next if /^\s*`/ || $line =~ /NOT\s+NULL/i;
    if ($line =~ /^\s+(`\w+?`)/) {
      push @$null_allowed_column, $1;
    }
  }
  return $null_allowed_column;
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

sub show_charsets {
  my ($self, $database) = @_;
  
  my $tables = $self->show_tables($database);
  my $charsets = {};
  for my $table (@$tables) {
    my $charset = $self->show_charset($database, $table);
    $charsets->{$table} = $charset;
  }
  
  return $charsets;
}

sub show_charset {
  my ($self, $database, $table) = @_;
  
  my $show_create_table = $self->show_create_table($database, $table) || '';
  my $charset = '';
  if ($show_create_table =~ /CHARSET=(.+?)(\s+|$)/i) {
    $charset = $1;
  }
  
  return $charset;
}

sub show_databases {
  my $self = shift;
  
  my $databases = [];
  my $database_rows = $self->dbi->execute('show databases')->all;
  for my $database_row (@$database_rows) {
    push @$databases, $database_row->{(keys %$database_row)[0]};
  }
  return $databases;
}

sub show_tables { 
  my ($self, $database) = @_;
  my $tables = $self->dbi->execute("show tables from $database")->values;
  return $tables;
}

sub show_create_table {
  my ($self, $database, $table) = @_;
  my $table_def_row;
  eval { $table_def_row = $self->dbi->execute("show create table $database.$table")->one };
  $table_def_row ||= {};
  my $table_def = $table_def_row->{'Create Table'} || '';
  return $table_def;
}

1;
