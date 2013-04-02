# PAF DB Viewer

Database viewer to see database information on web browser

# Features

* Perl 5.8.7+ only needed
* Support MySQL and SQLite
* Display all table names
* Display show create table
* Execute simple select statement
* Display primary keys, null allowed columnes, database engines, and charsets in all tables.

# Instllation into Shared Server (Linux/Unix, Apache, SuExec, PHP5(CGI mode))

Sahred Server must support Linux/Unix, Apache, SuExec, and PHP5(CGI mode).
Many shared server support these,
so you will find needed server easily.

## Download

You donwload pafdbviewer.

https://github.com/yuki-kimoto/pafdbviewer/archive/0.01.zip

You expand zip file. You see the following directory.

    pafdbviewer-0.01

Rename this pafdbviewer-0.01 to pafdbviewer.

    pafdbviewer-0.01 -> pafdbviewer

## Add database information

You must set database information into **pafdbviewer.conf**.
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

    http://(Your host name)/pafdbviewer/setup/setup.php

(If you see forbidden message, you set this file permission to **755**.)

And click Setup button once and wait abount 5 minutes.

## Go to application

If you see result, click "Go to Application".

## You see Internal Server Error

If you see internal server error, you see pafdbviewer/log/production.log.
You know what error is happned.

## Copyright & license

Copyright 2013-2013 Perl Application Factory(Yuki Kimoto)
all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
