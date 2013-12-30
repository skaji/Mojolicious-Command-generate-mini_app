use strict;
use warnings;
use utf8;
use Test::More;
use File::Temp qw(tempdir);
use File::pushd qw(pushd);

my $tempdir = tempdir CLEANUP => 1;

subtest invalid => sub {
    my $guard = pushd $tempdir;
    mkdir "already";
    my @out = `mojo generate mini_app already 2>&1`;
    ok $? != 0;
};

subtest valid => sub {
    my $guard = pushd $tempdir;
    my @out = `mojo generate mini_app test 2>&1`;
    $? == 0 or die "failed to mojo generate mini_app test";
    ok -d 'test';
    my $found;
    for (@out) {
        $found++ if /(app\.pl|app\.conf|\.gitignore|cpanfile)$/;
    }
    is $found, 4;
    diag @out;
};





done_testing;

