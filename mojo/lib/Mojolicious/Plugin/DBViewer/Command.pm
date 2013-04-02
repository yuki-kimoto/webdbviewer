package Mojolicious::Plugin::DBViewer::Command;
use Mojo::Base -base;

use Carp 'croak';

has 'dbi';

sub show_primary_keys {
  my ($self, $database) = @_;

  my $tables = $self->show_tables($database);
  my $primary_keys = {};
  for my $table (@$tables) {
    my $primary_key = $self->show_primary_key($database, $table);
    $primary_keys->{$table} = $primary_key;
  }
  return $primary_keys;
}

sub show_null_allowed_columns {
  my ($self, $database) = @_;
  my $tables = $self->show_tables($database);
  my $null_allowed_columns = {};
  
  for my $table (@$tables) {
    my $null_allowed_column = $self->show_null_allowed_column($database, $table);
    $null_allowed_columns->{$table} = $null_allowed_column;
  }
  return $null_allowed_columns;
}

sub show_null_allowed_column { croak "Unimplemented" }

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

sub params {
  my ($self, $c) = @_;
  my $params = {map {$_ => scalar $c->param($_)} $c->param};
  return $params;
}

1;
