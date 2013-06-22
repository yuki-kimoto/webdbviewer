use Test::More 'no_plan';
use strict;
use warnings;

use FindBin;


use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../mojo/lib";
use lib "$FindBin::Bin/../extlib/lib/perl5";

use Test::Mojo;
use Webdbviewer;

# Test Config
$ENV{WEBDBVIEWER_TEST_CONF_FILE} = "$FindBin::Bin/test.conf";

# App
my $app = Webdbviewer->new;
my $config = $app->config;

# Test
my $t = Test::Mojo->new($app);

$t->get_ok('/')->content_like(qr/Web DB Viewer/);
$t->content_like(qr/main/);

# Config
is($config->{basic}{dbtype}, 'sqlite');
like($config->{basic}{dbname}, qr#t/test\.db#);
is($config->{basic}{user}, 'kimoto');
is($config->{basic}{password}, 'a');
is($config->{basic}{host}, 'some.com');
is($config->{basic}{port}, 10000);
is($config->{basic}{site_title}, 'Web DB Viewer');
is_deeply($config->{hypnotoad}{listen}, ['http://*:10030']);
is($config->{mysql}{mysql_read_default_file}, '/etc/my.cnf');
is($config->{mysql}{set_names}, 'ujis');
is_deeply($config->{_join_normalized}, {book => ['left join author on book.author_id = author.id', 'left join title on book.title_id = title.id']});

# Tables
$t->get_ok('/tables?database=main');
$t->content_like(qr/table1/);
