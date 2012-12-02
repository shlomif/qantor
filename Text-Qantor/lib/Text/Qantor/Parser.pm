package Text::Qantor::Parser::Foo;

use strict;
use warnings;

use Text::Qantor::Parser::Elem::Para;
use Text::Qantor::Parser::Elem::ParaList;
use Text::Qantor::Parser::Elem::MacroCall;

use Moose;

extends ('Parser::MGC');

sub new
{
    my $self = shift;

    return $self->Parser::MGC::new(
        patterns => {
            ws => qr//,
        },
    );
}

sub parse
{
    my $self = shift;

    return $self->_parse_Input();
}

sub _parse_Input
{
    my $self = shift;

    my $Text = $self->_parse_Text();

    $self->maybe(
        sub {
            $self->_parse_Empty_Line();
        }
    );

    return { Text => $Text, };
}

sub _parse_Text
{
    my $self = shift;

    my $paras = $self->list_of(
        qr/(?:(?:\h*(?:\n|\z)))+/ms,
        sub { $self->_parse_Raw_Para(); },
    );

    return {Raw_Para => $paras};
}

sub _parse_Raw_Para
{
    my ($self) = @_;

    my $Para_Text_Wrapper_s = $self->list_of(
        qr/\n(?!\n)/,
        sub { $self->_parse_Para_Text_Wrapper(); }
    );

=begin foo

    if (!$self->at_eos() ) {
        $self->generic_token('Single_Empty_line' => qr/(?:(?:\n\n)|(?:\n\z)|\z)/,
            sub { my ($self, $text) = @_; return $text; },
        );
    }

=end foo

=cut

    return
    +{
        Para_Text_Wrapper => $Para_Text_Wrapper_s,
    };
}

sub _parse_Single_Empty_Line
{
    my ($self) = @_;

    return $self->generic_token('Single_Empty_line' => qr/(?:\h*(?:\n|\z))/ms,
        sub { my ($self, $text) = @_; return $text; },
    );
}

sub _parse_Empty_Line
{
    my $self = shift;

    my $ret = $self->generic_token(
        'Single_Empty_line' => qr/(?:(?:\h*(?:\n|\z)))+/ms,
        sub { my ($self, $text) = @_; return $text; },
    );

    return $ret;
}

sub _parse_Para_Text_Wrapper
{
    my $self = shift;

    return $self->any_of(
        sub { $self->_parse_Plain_Para_Text(); },
        sub { $self->_parse_Macro_Para_Text(); },
    );
}

sub _parse_Macro_Para_Text
{
    my $self = shift;

    my $start = $self->_parse_MACRO_START();

    if (! $start) {
        $self->fail();
    }

    my $name = $self->_parse_MACRO_NAME();

    my $inner = $self->scope_of(
        qr/\{/,
        sub { return $self->_parse_Raw_Para(); },
        qr/\}/,
    );

    return { MACRO_NAME => $name, inner => $inner, };
}

sub _parse_MACRO_START
{
    my ($self) = @_;

    return $self->generic_token('MACRO_START' => qr/(\\(?=\w))/,
        sub { my ($self, $text) = @_; return $text; },
    );
}

sub _parse_MACRO_NAME
{
    my ($self) = @_;

    return $self->generic_token('MACRO_NAME' => qr/(\w+)/,
        sub { my ($self, $text) = @_; return $text; },
    );
}

sub _parse_MACRO_BODY_START
{
    my ($self) = @_;

    return $self->generic_token('MACRO_BODY_START' => q/\{/,
        sub { my ($self, $text) =  @_; return $text; },
    );
}

sub _parse_MACRO_BODY_END
{
    my ($self) = @_;

    return $self->generic_token('MACRO_BODY_END' => q/\}/,
        sub { my ($self, $text) = @_; return $text; },
    );
}

sub _parse_Plain_Para_Text
{
    my ($self) = @_;

    my $token = $self->generic_token(
        'Plain_Para_Text' => qr/(?:[^\\\n\{\}]+(?!\n{2})?)/ms,
        sub { my ($self, $text) = @_; return {Plain_Para_Text => $text}; },
    );

    my $suffix = '';
    if ($self->{str} =~ m/\G(?=\n)/gc) {
        $suffix = "\n";
    }

    if (not length($token)) {
        $self->fail();
    }

    $token->{Plain_Para_Text} .= $suffix;

    return $token;
}

=begin Removed

    my $parser = do {

        use Regexp::Grammars;

        qr/
        # <logfile: - >
        # <debug: on>

        \A <Input> \z

        <token: Input>
            <Text> (?:<.Empty_Line>)?
        <token: Text>
            <[Raw_Para]> ** <Empty_Line>
        <token: Raw_Para>
            <[Para_Text_Wrapper]>+
        <token: Single_Empty_Line>
            <.Match=(?:^\s*(?:\n|\z))>
        <token: Empty_Line>
            <.Single_Empty_Line>+
        <token: Para_Text_Wrapper>
            <Plain_Para_Text>
                |
            <Macro_Para_Text>
        <token: Macro_Para_Text>
            <MACRO_START> <MACRO_NAME> <MACRO_BODY_START> <Raw_Para> <MACRO_BODY_END>
        <token: MACRO_START> <.MATCH= (\\(?=\w)) >
        <token: MACRO_NAME> <MATCH= (\w+) >
        <token: MACRO_BODY_START> <.MATCH= (?:\{) >
        <token: MACRO_BODY_END> <.MATCH= (?:\}) >

        <token: Para_Text>
            <Macro_Para_Text>
                |
            <Plain_Para_Text>

        <token: Plain_Para_Text> <MATCH= ([^\\\n\{\}]+\n?) >
        /msx;

    };
}

=end Removed

=cut

=head1 NAME

Text::Qantor::Parser - parser for Qantor.

=head1 DESCRIPTION

=head1 FUNCTIONS

=head2 my $qantor_parser = Text::Qantor::Parser->new()

Constructs a new parser instance.

=head2 my $tree = $qantor_parser->parse({text => $text});

Parses $text using the parser.


=cut

package Text::Qantor::Parser;

use Moose;

extends ('Text::Qantor::Parser::Foo');

=begin foo

around qr/\A_parse/ => sub {
    my ($orig, $self, @params) = @_;

    print "In [$orig] Now is: <<" . substr($self->{str}, $self->pos()) . ">>\n";

    return $self->$orig(@params);
};

=end foo

=cut

foreach my $meth (
qw(
_parse_Input
_parse_Text
_parse_Raw_Para
_parse_Single_Empty_Line
_parse_Empty_Line
_parse_Para_Text_Wrapper
_parse_Macro_Para_Text
_parse_MACRO_START
_parse_MACRO_NAME
_parse_MACRO_BODY_START
_parse_MACRO_BODY_END
_parse_Plain_Para_Text
)
)
{
    around $meth => sub {
        my ($orig, $self, @params) = @_;

        # print "In [$meth] Now is: <<" . substr($self->{str}, $self->pos()) . ">>\n";

        my $ret = $self->$orig(@params);

        use Data::Dumper;
        # print "In [$meth] consumed <<" . Dumper($ret) . ">>\n";

        return $ret;
    };
}
1;

=begin Foo


=end Foo

=cut
