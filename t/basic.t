#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;

my $pkg;
BEGIN {
    $pkg = 'Catmandu::Exporter::Template';
    use_ok $pkg;
}
require_ok $pkg;

my $file = "";
my $template = <<EOF;
Author: [% author %]
Title: "[% title %]"
EOF

my $exporter = $pkg->new(file => \$file, template => \$template);
my $data = {
	author => "brian d foy",
	title => "Mastering Perl",
};

can_ok $exporter, "add";
can_ok $exporter, "commit";

$exporter->add($data);
$exporter->commit;
my $result = <<EOF;
Author: brian d foy
Title: "Mastering Perl"
EOF

is ($file, $result, "Exported Format");

done_testing 5;
