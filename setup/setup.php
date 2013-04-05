<?php
  # Setup directory
  $setup_dir = getcwd();

  # Home directory
  $home_dir = realpath($setup_dir . '/..');
  
  # Script directory
  $script_dir = realpath($setup_dir . '/../script');
  
  # cpanm Path
  $cpanm_path = "$home_dir/cpanm";
  
  # cpanm home directory
  putenv("PERL_CPANM_HOME=$setup_dir");
  
  # Parameter
  $op = $_REQUEST['op'];
  
  # Setup script absolute path
  $setup_script_abs_path = $_SERVER["SCRIPT_NAME"];
  
  # Application script absolute path
  $app_abs_path = $setup_script_abs_path;
  $app_abs_path
    = preg_replace('/\/setup\/setup\.php/', '', $app_abs_path) . '.cgi';
  
  # Application script name
  preg_match("/([0-9a-zA-Z-_]+\.cgi)$/", $app_abs_path, $matches);
  $app_name = $matches[0];
  
  # Application script file
  $app_file = "$script_dir/$app_name";
  
  # Place Application script is moved to 
  $app_to = realpath("$home_dir/../$app_name");
  
  $output = array();
  $success = true;
  
  if($op == 'setup') {
    
    if (!chdir($home_dir)) {
      throw new Exception("Can't cahgne directory");
    }
    exec("perl cpanm -n -l extlib Module::CoreList 2>&1", $output, $ret);
    
    $output = array();
    if ($ret == 0) {
      exec("perl -Iextlib/lib/perl5 cpanm -n -L extlib --installdeps . 2>&1", $output, $ret);
      if ($ret == 0) {
        if (copy($app_file, $app_to)) {
          array_push($output, "$app_file is moved to $app_to");
          if (chmod($app_to, 0755)) {
            array_push($output, "change $app_to mode to 755");
            $success = true;
          }
          else {
            array_push($output, "Can't change mode $app_to");
            $success = false;
          }
        }
        else {
          array_push($output, "Can't move $app_file to $app_to");
          $success = false;
        }
      }
      else {
        $success = false;
      }
    }
    else {
      $success = false;
    }
  }
?>

<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title>Setup Tool</title>
    <script src="js/jquery-1.9.0.min.js"></script>
    <script src="js/bootstrap.js"></script>
    <link rel="stylesheet" href="css/bootstrap.css" />
    <link rel="stylesheet" href="css/bootstrap-responsive.css" />
  </head>
  <body>
    <div class="container">
      <div class="text-center"><h1>Setup Tool</h1></div>
    </div>
    <hr style="margin-top:0;margin-bottom:0">
    <div class="container">
      <div class="text-center"><b><h3>Click!</h3></b></div>
      <form action="<?php echo "$setup_script_abs_path?op=setup" ?>" method="post">
        <div class="text-center" style="margin-bottom:10px">
          <input type="submit" style="width:200px;height:50px;font-size:200%" value="Setup">
        </div>
      </form>

<?php if ($op == 'setup') { ?>
      <span class="label">Result</span>
<pre style="height:300px;overflow:auto;margin-bottom:30px">
<?php if (!$success) { ?>
<span style="color:red">Error, Setup failed.</span>
<?php } ?>
<?php if ($success) { ?>
<?php foreach ($output as $line) { ?>
<?php echo htmlspecialchars($line) ?>

<?php } ?>
<?php } ?>
</pre>
<?php } ?>

      <?php if ($op == 'setup' && $success) { ?>
        <div style="font-size:150%;margin-bottom:30px;">Go to <a href="<?php echo $app_abs_path ?>">Application</a></div>
      <?php } ?>
    </div>
  </body>
</html>
