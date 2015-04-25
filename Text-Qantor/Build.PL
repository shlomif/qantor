use strict;
use warnings;

use File::Spec;
use lib File::Spec->catdir(File::Spec->curdir(), "inc");

use Text::Qantor::Builder;

my $builder = Text::Qantor::Builder->new(
    module_name         => 'Text::Qantor',
    license             => 'mit',
    dist_author         => 'Shlomi Fish <shlomif@cpan.org>',
    dist_version_from   => 'lib/Text/Qantor.pm',
    requires => {
        'Carp' => 0,
        'Exporter' => 0,
        'File::Spec' => 0,
        'Moose' => 0,
        'Parser::MGC' => 0,
        'XML::LibXML' => 0,
        'XML::LibXSLT' => 0,
        'XML::Writer' => 0,
        'strict' => 0,
        'vars' => 0,
        'version' => 0,
        'warnings' => 0,
    },
    build_requires => {
        'Moose' => 0,
        # 'Regexp::Grammars' => 0,
        'Test::More' => 0,
        'version' => 0,
    },
    add_to_cleanup      => [ 'Text-Qantor-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
