#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use Catmandu::Exporter::Template;

my $file     = "";
my $template = <<EOF;
Author: <% author !>
Title: "<% title !>"
EOF

my $exporter = Catmandu::Exporter::Template->new(
    file      => \$file,
    template  => \$template,
    start_tag => "<%",
    end_tag   => "!>"
);
my $data = {
    author => "brian d foy",
    title  => "Mastering Perl",
};

$exporter->add($data);

my $result = <<EOF;
Author: brian d foy
Title: "Mastering Perl"
EOF

is( $file, $result, "Exported Format" );

my $template2 = <<EOF;
Author: <? author ?>
Title: "<? title ?>"
EOF

my $exporter2 = Catmandu::Exporter::Template->new(
    file      => \$file,
    template  => \$template,
    tag_style => "php"
);
$exporter2->add($data);

is( $file, $result, "Tag style ok" );

done_testing 2;
