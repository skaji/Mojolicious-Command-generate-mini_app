package Mojolicious::Command::generate::mini_app;
use Mojo::Base 'Mojolicious::Command';

our $VERSION = "0.001";

my $bootstrap_url = 'http://netdna.bootstrapcdn.com/bootstrap';
my $jquery_url    = 'http://code.jquery.com';
my %PUBLIC = (
    'css/bootstrap.min.css'   => "$bootstrap_url/3.0.3/css/bootstrap.min.css",
    'js/bootstrap.min.js'     => "$bootstrap_url/3.0.3/js/bootstrap.min.js",
    'js/jquery-2.0.3.min.js'  => "$jquery_url/jquery-2.0.3.min.js",
    'js/jquery-2.0.3.min.map' => "$jquery_url/jquery-2.0.3.min.map",
);

has description => "Generate minimal application.\n";
has usage       => "usage: $0 generate mini_app [DIRNAME]\n";

sub run {
    my ($self, $dir) = @_;
    $dir ||= "mini_app";
    die "ERROR $dir is an invalid directory name.\n" if $dir !~ /^[a-z0-9_.-]+$/i;
    die "ERROR There already exists $dir.\n" if -d $dir;

    my $ua = $self->app->ua;
    while (my ($file, $url) = each %PUBLIC) {
        my $tx = $ua->get($url);
        if (my $res = $tx->success) {
            $self->write_rel_file("$dir/public/$file", $res->body);
        } else {
            my ($err, $code) = $tx->error;
            die "ERROR failed to request $url: " . $code ? "$code $err" : $err;
        }
    }

    $self->render_to_rel_file(".gitignore", "$dir/.gitignore");
    $self->render_to_rel_file("cpanfile",   "$dir/cpanfile");
    $self->render_to_rel_file("app.pl",     "$dir/app.pl");
    $self->render_to_rel_file("app.conf",   "$dir/app.conf");
}

1;
__DATA__

@@ .gitignore
/*.pid
/log/*.log

@@ cpanfile
requires 'perl', '5.010001';
requires 'Mojolicious';

@@ app.conf
#!perl
use strict;
use warnings;
use utf8;
{
    hypnotoad => {
        listen => ['http://*:3003'],
    },
}

@@ app.pl
#!/usr/bin/env perl
use Mojolicious::Lite;

my $config = plugin 'Config';

get '/' => sub {
    my $self = shift;
    $self->render('index');
};

app->start;

<% %>__DATA__

<% %>@@ index.html.ep
%% layout 'default';
%% title 'mojo app';
<div class="page-header">
    <h1>mojo app</h1>
</div>
Welcome to the Mojolicious real-time web framework!

<% %>@@ layouts/default.html.ep
<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
%%= stylesheet '/css/bootstrap.min.css'
<title><%%= title %></title>
</head>
<body>
<div class="container">
<%%= content %>
</div>
%%= javascript '/js/jquery-2.0.3.min.js'
%%= javascript '/js/bootstrap.min.js'
</body>
</html>

__END__

=encoding utf-8

=head1 NAME

Mojolicious::Command::generate::mini_app - generate minimal Mojolicious application

=head1 SYNOPSIS

    % mojo generate mini_app myapp

=head1 DESCRIPTION

Mojolicious::Command::generate::mini_app generates minimal Mojolicious application.

=head1 LICENSE

Copyright (C) Shoichi Kaji.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Shoichi Kaji E<lt>skaji@outlook.comE<gt>

=cut

