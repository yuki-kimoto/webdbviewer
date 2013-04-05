# Web DB Viewer

Database viewer to see database information on web browser

# Screen Shot

<img src="http://cdn-ak.f.st-hatena.com/images/fotolife/p/perlcodesample/20130405/20130405165125_original.png" width="850">

# Features

* Perl 5.8.7+ only needed
* Support MySQL and SQLite
* Display all table names
* Display show create table
* Execute simple select statement
* Display primary keys, null allowed columnes, database engines, and charsets in all tables.

# Installation into Shared Server (Linux/Unix, Apache, SuExec, PHP5(CGI mode))

Sahred Server must support Linux/Unix, Apache, SuExec, and PHP5(CGI mode).
Many shared server support these,
so you will find needed server easily.

## Download

You donwload webdbviewer.

https://github.com/yuki-kimoto/webdbviewer/archive/0.01.zip

You expand zip file. You see the following directory.

    webdbviewer-0.01

Rename this webdbviewer-0.01 to webdbviewer.

    webdbviewer-0.01 -> webdbviewer

## Configuration

You must set database information into **webdbviewer.conf**.
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

(If you see forbidden message, you set this file permission to **755**.)

And click Setup button once and wait abount 5 minutes.

## Go to application

If you see result, click "Go to Application".

## You see Internal Server Error

If you see internal server error, you see webdbviewer/log/production.log.
You know what error is happned.

## Copyright & license

Copyright 2013-2013 Yuki Kimoto all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

# Instllation into Your Server (Unix/Linux)

Web DB Viewer have own web server,
so you can execute application very easy.

## Create webdbviewer user

At first create **webdbviewer** user. This is not nesessary, but recommended.

    useradd webdbviewer
    su - webdbviewer
    cd ~

## Download

Download tar.gz archive and exapand it and change directory. 

    curl -kL https://github.com/yuki-kimoto/webdbviewer/archivewebdbviewer-0.03.tar.gz > webdbviewer-0.03.tar.gz
    tar xf webdbviewer-0.03.tar.gz
    cd webdbviewer-0.03

## Setup

You execute the following command. Needed moudles is installed.

    ./setup.sh

## Test

Do test to check setup process is success or not.

    prove t

If "All tests successful." is shown, setup process is success.

## Configuration

Same as above Configuration section.

## Operation

### Start

You can start application start.
Application is run in background, port is **10030** by default.

    ./webdbviewer

You can access the following URL.
      
    http://localhost:10030
    
If you change port, edit webdbviewer.conf.

### Stop

You can stop application by **--stop** option.

    ./webdbviewer --stop

### Operation by root user

If you want to do operation by root user,
you must do some configuration for security.

You add **user** and **group** to **hypnotoad** section in **webdbviewer.conf**.

    [hypnotoad]
    ...
    user=webdbviewer
    group=webdbviewer

Start application

    /home/webdbviewer/webdbviewer

Stop application

    /home/webdbviewer/webdbviewer --stop

### Developer

If you are developer, you can start application development mode

    ./morbo

You can access the following URL.
      
    http://localhost:3000
