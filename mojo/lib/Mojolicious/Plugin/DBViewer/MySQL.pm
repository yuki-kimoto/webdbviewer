package Mojolicious::Plugin::DBViewer::MySQL::Main;
use Mojo::Base 'Mojolicious::Controller';
use Data::Page;

sub default {
  my $self = shift;
  
  my $plugin = $self->stash->{plugin};
  my $command = $plugin->command;
  
  my $database = $command->show_databases;
  my $current_database = $command->current_database;

  $self->render(
    databases => $database,
    current_database => $current_database,
  );
}

sub tables {
  my $self = shift;;
  
  my $plugin = $self->stash->{plugin};
  my $command = $plugin->command;

  my $params = $command->params($self);
  my $rule = [
    database => {default => ''} => [
      'safety_name'
    ] 
  ];
  my $vresult = $plugin->validator->validate($params, $rule);
  my $database = $vresult->data->{database};
  my $tables = $command->show_tables($database);
  
  return $self->render(
    database => $database,
    tables => $tables
  );
}

sub table {
  my $self = shift;;
  
  my $plugin = $self->stash->{plugin};
  my $command = $plugin->command;

  # Validation
  my $params = $command->params($self);
  my $rule = [
    database => {default => ''} => [
      'safety_name'
    ],
    table => {default => ''} => [
      'safety_name'
    ]
  ];
  my $vresult = $plugin->validator->validate($params, $rule);
  my $database = $vresult->data->{database};
  my $table = $vresult->data->{table};
  
  my $table_def = $command->show_create_table($database, $table);

  return $self->render(
    database => $database,
    table => $table, 
    table_def => $table_def,
  );
}

sub showcreatetables {
  my $self = shift;;
  
  my $plugin = $self->stash->{plugin};
  my $command = $plugin->command;

  # Validation
  my $params = $command->params($self);
  my $rule = [
    database => {default => ''} => [
      'safety_name'
    ]
  ];
  my $vresult = $plugin->validator->validate($params, $rule);
  my $database = $vresult->data->{database};
  my $tables = $command->show_tables($database);
  
  # Get create tables
  my $create_tables = {};
  for my $table (@$tables) {
    $create_tables->{$table} = $plugin->command->show_create_table($database, $table);
  }
  
  $self->render(
    database => $database,
    create_tables => $create_tables
  );
}

sub showselecttables {
  my $self = shift;;
  
  my $plugin = $self->stash->{plugin};
  my $command = $plugin->command;

  # Validation
  my $params = $command->params($self);
  my $rule = [
    database => {default => ''} => [
      'safety_name'
    ]
  ];
  my $vresult = $plugin->validator->validate($params, $rule);
  my $database = $vresult->data->{database};
  my $tables = $command->show_tables($database);
  
  $self->render(
    database => $database,
    tables => $tables
  );
}

sub showprimarykeys {
  my $self = shift;;
  
  my $plugin = $self->stash->{plugin};
  my $command = $plugin->command;

  # Validation
  my $params = $command->params($self);
  my $rule = [
    database => {default => ''} => [
      'safety_name'
    ],
  ];
  my $vresult = $plugin->validator->validate($params, $rule);
  my $database = $vresult->data->{database};
  
  # Get primary keys
  my $primary_keys = $command->show_primary_keys($database);
  
  $self->render(
    database => $database,
    primary_keys => $primary_keys
  );
}

sub shownullallowedcolumns {
  my $self = shift;;
  
  my $plugin = $self->stash->{plugin};
  my $command = $plugin->command;

  # Validation
  my $params = $command->params($self);
  my $rule = [
    database => {default => ''} => [
      'safety_name'
    ],
  ];
  my $vresult = $plugin->validator->validate($params, $rule);
  my $database = $vresult->data->{database};
  
  # Get null allowed columns
  my $null_allowed_columns = $command->show_null_allowed_columns($database);
  
  $self->render(
    database => $database,
    null_allowed_columns => $null_allowed_columns
  );
}

sub select {
  my $self = shift;;
  
  my $plugin = $self->stash->{plugin};
  my $command = $plugin->command;

  # Validation
  my $params = $command->params($self);
  my $rule = [
    database => {default => ''} => [
      'safety_name'
    ],
    table => {default => ''} => [
      'safety_name'
    ],
    page => {default => 1} => [
      'uint'
    ],
    c1 => [
      'safety_name'
    ],
    v1 => [
      'not_blank'
    ]
  ];
  my $vresult = $plugin->validator->validate($params, $rule);
  my $database = $vresult->data->{database};
  my $table = $vresult->data->{table};
  
  # Where
  my $column = $vresult->data->{c1};
  my $value = $vresult->data->{v1};
  
  my $where;
  if (defined $column && defined $value) {
    $where = $plugin->dbi->where;
    $where->clause(":${column}{like}");
    $where->param({$column => $value});
  }
  
  # Limit
  my $page = $vresult->data->{page};
  my $count = 100;
  my $offset = ($page - 1) * $count;
  
  # Get null allowed columns
  my $result = $plugin->dbi->select(
    table => "$database.$table",
    where => $where,
    append => "limit $offset, $count"
  );
  my $header = $result->header;
  my $rows = $result->fetch_all;
  my $sql = $plugin->dbi->last_sql;
  
  # Pager
  my $total = $plugin->dbi->select(
    'count(*)',
    table => "$database.$table",
    where => $where
  )->value;
  my $pager = Data::Page->new($total, $count, $page);
  
  $self->render(
    database => $database,
    table => $table,
    header => $header,
    rows => $rows,
    sql => $sql,
    pager => $pager
  );
}

sub showdatabaseengines {
  my $self = shift;;
  
  my $plugin = $self->stash->{plugin};
  my $command = $plugin->command;

  # Validation
  my $params = $command->params($self);
  my $rule = [
    database => {default => ''} => [
      'safety_name'
    ],
  ];
  my $vresult = $plugin->validator->validate($params, $rule);
  my $database = $vresult->data->{database};
  
  # Get primary keys
  my $database_engines = $command->show_database_engines($database);
  
  $self->stash->{template} = 'mysqlviewerlite/showdatabaseengines'
    unless $self->stash->{template};

  $self->render(
    database => $database,
    database_engines => $database_engines
  );
}

sub showcharsets {
  my $self = shift;;
  
  my $plugin = $self->stash->{plugin};
  my $command = $plugin->command;

  # Validation
  my $params = $command->params($self);
  my $rule = [
    database => {default => ''} => [
      'safety_name'
    ],
  ];
  my $vresult = $plugin->validator->validate($params, $rule);
  my $database = $vresult->data->{database};
  
  # Get primary keys
  my $charsets = $command->show_charsets($database);
  
  $self->stash->{template} = 'mysqlviewerlite/showcharsets'
    unless $self->stash->{template};

  $self->render(
    database => $database,
    charsets => $charsets
  );
}

1;
