# WebDBViewer

Database viewer to see database information on web browser.

<img src="http://cdn-ak.f.st-hatena.com/images/fotolife/p/perlcodesample/20130630/20130630082021_original.png" width="800">

# Features

* Display database information on web browser.
* Support MySQL and SQLite.
* Execute simple select statement.
* Join mode support, You can search rows using joined table's column condition.
* Display table names, show create table, primary keys, null allowed columnes, database engines, and charsets.
* CGI support, and having built-in prefork web werver which reverse proxy support.
* Support many operating system. Unix, Linux, and cygwin on Windows.
* Perl 5.8.7+ only needed.

## Check Perl Version

Check Perl version. You can use webdbviewer if the Perl version is 5.8.7+;

    perl -v

## A. Installation when you run webdbviewer as CGI script

Download tar.gz archive, expand it and change directory:

    curl -kL https://github.com/yuki-kimoto/webdbviewer/archive/latest.tar.gz > webdbviewer-latest.tar.gz
    tar xf webdbviewer-latest.tar.gz
    mv webdbviewer-latest webdbviewer
    cd webdbviewer

Setup. Needed module is installed.

    ./setup.sh

Check setup. Run the following command.

    prove t

If "syntax OK" is displayed, setup is sucseed.

You must set database information in **webdbviewer.conf**.
database type, database name, user, password, host, or port.
(; is comment line)

    [basic]
    ;;; Database type
    ; dbtype=mysql
    ; dbtype=sqlite
    dbtype=mysql

    ;;; Database name
    dbname=myproject

    ;;; User
    user=kimoto

    ;;; Password
    password=secret

    ;;; Host
    ;host=yourhost.com

    ;;; Port
    ;port=1234
    
You can access the following URL.

    http://yourhost/somepath/webdbviewer/webdbviewer.cgi

### If you see Internal Server Error

If you see an internal server error, look at the log file (webdbviewer/log/production.log)
to see what problem has occurred.

### Additional work when you don't run CGI script by your user.

If CGI script isn't run by your user, you need the following work.
For example, CGI script is run by apache user.

Change user and group of all files in webdbviewer directory to apache 

    chown -R apache:apache webdbviewer

In this case, you server need to execute CGI.
Check apache config file.

For example, you need the following config.

    <Directory /var/www/html>
        Options +ExecCGI
        AddHandler cgi-script .cgi
    </Directory>

## B. Installation when you run webdbviewer as embdded web server

webdbviewer has its own web server,
so you can start using the application very easily.
In this way, performance is much better than CGI.

### Create webdbviewer user

Create a **webdbviewer** user. This is not necessary, but recommended:

    useradd webdbviewer
    su - webdbviewer
    cd ~

### Download

Download tar.gz archive, expand it and change directory:

    curl -kL https://github.com/yuki-kimoto/webdbviewer/archive/latest.tar.gz > webdbviewer-latest.tar.gz
    tar xf webdbviewer-latest.tar.gz
    mv webdbviewer-latest webdbviewer
    cd webdbviewer

Setup. Needed module is installed.

    ./setup.sh

Check setup. Run the following command.

    prove t

If "syntax OK" is displayed, setup is sucseed.

You must set database information in **webdbviewer.conf**.
database type, database name, user, password, host, or port.
(; is comment line)

    [basic]
    ;;; Database type
    ; dbtype=mysql
    ; dbtype=sqlite
    dbtype=mysql

    ;;; Database name
    dbname=myproject

    ;;; User
    user=kimoto

    ;;; Password
    password=secret

    ;;; Host
    ;host=yourhost.com

    ;;; Port
    ;port=1234

### Start

You can start the application by running the provided webdbviewer script.
The application is run in the background and the port is **10020** by default.

    ./webdbviewer

Then access the following URL.

    http://localhost:10020

If you want to change the port, edit webdbviewer.conf.
If you cannot access this port, you might change the firewall settings.

### Stop

You can stop the application by adding the **--stop** option.

    ./webdbviewer --stop
    
## Developer

If you are developer, you can start application development mode

    ./morbo

You can access the following URL.
      
    http://localhost:3000

If you have git, it is easy to install from git.

    git clone git://github.com/yuki-kimoto/webdbviewer.git

It is useful to write configuration in ***webdbviewer.my.conf***
, not webdbviewer.conf.

## Web Site

[WebDBViewer Site](http://perlcodesample.sakura.ne.jp/webdbviewer-site/)

## Internally Using Library

* [Config::Tiny](http://search.cpan.org/dist/Config-Tiny/lib/Config/Tiny.pm)
* [DBD::SQLite](http://search.cpan.org/dist/DBD-SQLite/lib/DBD/SQLite.pm)
* [DBI](http://search.cpan.org/dist/DBI/DBI.pm)
* [DBIx::Connector](http://search.cpan.org/dist/DBIx-Connector/lib/DBIx/Connector.pm)
* [DBIx::Custom](http://search.cpan.org/dist/DBIx-Custom/lib/DBIx/Custom.pm)
* [Mojolicious](http://search.cpan.org/~kimoto/DBIx-Custom/lib/DBIx/Custom.pm)
* [Mojolicious::Plugin::INIConfig](http://search.cpan.org/dist/Mojolicious-Plugin-INIConfig/lib/Mojolicious/Plugin/INIConfig.pm)
* [mojo-legacy](https://github.com/jamadam/mojo-legacy)
* [Object::Simple](http://search.cpan.org/dist/Object-Simple/lib/Object/Simple.pm)
* [Validator::Custom](http://search.cpan.org/dist/Validator-Custom/lib/Validator/Custom.pm)

## Sister project

* [webdbviewer](https://github.com/yuki-kimoto/gitprep) - Github clone. you can install portable github system into unix/linux.

## Copyright & license

Copyright 2013-2013 Yuki Kimoto all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
