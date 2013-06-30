# Web DB Viewer

Database viewer to see database information on web browser.

<img src="http://cdn-ak.f.st-hatena.com/images/fotolife/p/perlcodesample/20130405/20130405170135_original.png?1365148885" width="850">

# Features

* Display database information on web browser.
* Support MySQL and SQLite.
* Execute simple select statement.
* Join mode support, You can search rows using joined table's column condition.
* Display table names, show create table, primary keys, null allowed columnes, database engines, and charsets.
* CGI support, and having built-in prefork web werver which reverse proxy support.
* Support many operating system. Unix, Linux, and cygwin on Windows.
* Perl 5.8.7+ only needed.

# Installation into Shared Server

Shared Server must support **Linux/Unix**, **Apache**, **SuExec**,
**CGI**, and **PHP5(CGI mode)**.

(PHP is not necessary, if PHP exists, install process is easy
because you don't need to think about permission.)

Many shared server support these,
so you will find sutable server easily.

## Download

You donwload webdbviewer.

https://github.com/yuki-kimoto/webdbviewer/archive/latest.zip

You expand zip file. You see the following directory.

    webdbviewer-latest

Rename this webdbviewer-latest to webdbviewer.

    webdbviewer-latest -> webdbviewer

## Configuration

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

## Upload Server by FTP

You upload these directory into server document root by FTP.

## Setup

Access the following URL by browser.

    http://(Your host name)/webdbviewer/setup/setup.php

(If you don't access PHP file or don't have PHP,
you can use CGI script
please set this CGI script permission to 755)

    http://(Your host name)/webdbviewer/setup/setup.cgi.

Click Setup button once and wait abount 5 minutes.

## Go to application

If you see result, click "Go to Application".

## You see Internal Server Error

If you see internal server error, you see webdbviewer/log/production.log.
You know what error is happned.

# Instllation into own Unix/Linux Server

Web DB Viewer have own web server,
so you can execute application very easy.
This is much better than above way
because you don't need to setup Apache environment,
and performance is much much better.

## Create webdbviewer user

At first create **webdbviewer** user. This is not nesessary, but recommended.

    useradd webdbviewer
    su - webdbviewer
    cd ~

## Download

Download tar.gz archive and exapand it and change directory. 

    curl -kL https://github.com/yuki-kimoto/webdbviewer/archive/latest.tar.gz > webdbviewer-latest.tar.gz
    tar xf webdbviewer-latest.tar.gz
    mv webdbviewer-latest webdbviewer
    cd webdbviewer

## Setup

You execute the following command. Needed moudles is installed.

    ./setup.sh

## Test

Do test to check setup process is success or not.

    prove t

If "All tests successful" is shown, setup process is success.

## Configuration

Same as Shared Server's Configuration section.

## Operation

### Start

You can start application start.
Application is run in background, port is **10030** by default.

    ./webdbviewer

You can access the following URL.
      
    http://localhost:10030
    
If you change port, edit webdbviewer.conf.
If you can't access this port, you might change firewall setting.

### Stop

You can stop application by **--stop** option.

    ./webdbviewer --stop

### Operation from root user

You can operation application from root user.

Start application

    sudo -u webdbviewer /home/webdbviewer/webdbviewer/webdbviewer

Stop application

    sudo -u webdbviewer /home/webdbviewer/webdbviewer/webdbviewer --stop

If you want to start application when os start,
add the start application command to **rc.local**(Linux).

If you want to make easy to manage webdbviewer,
Let's create run script.
    
    mkdir -p /webapp
    echo '#!/bin/sh' > /webapp/webdbviewer
    echo 'sudo -u webdbviewer /home/webdbviewer/webdbviewer/webdbviewer $*' >> /webapp/webdbviewer
    chmod 755 /webapp/webdbviewer

You can start and stop application the following command.
    
    # Start/Restart
    /webapp/webdbviewer
    
    # Stop
    /webapp/webdbviewer --stop
    
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

[Web DB Viewer Site](http://perlcodesample.sakura.ne.jp/webdbviewer-site/)

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

* [GitPrep](https://github.com/yuki-kimoto/gitprep) - Github clone. you can install portable github system into unix/linux.

## Copyright & license

Copyright 2013-2013 Yuki Kimoto all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
