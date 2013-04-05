use Test::More 'no_plan';
use FindBin;


use lib "$FindBin::Bin/../mojo/lib";
use lib "$FindBin::Bin/../extlib/lib/perl5";
use lib "$FindBin::Bin/../lib";

use Test::Mojo;
use Webdbviewer;

# Test Config
$EVN{WEBDBVIEWER_TEST_CONF_FILE} = "$FindBin::Bin/test.conf";

# App
my $app = Webdbviewer->new;

# Test
my $t = Test::Mojo->new($app);

$t->get_ok('/')->content_like(qr/Web DB Viewer/);
