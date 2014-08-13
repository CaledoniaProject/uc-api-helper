package W3::UC;

use strict;
use warnings;
use feature 'say';
use Data::Dumper;
use MIME::Base64;
use Digest::MD5 qw/md5_hex/;

use Exporter 'import';
our @ISA       = qw/Exporter/;
our @EXPORT_OK = qw/uc_encode/;

sub new {
    my ($class, %cfg) = @_;
	bless {}, $class;
}

sub uc_encode {
    my ($str, $key) = @_;
    my $ckey_len = 4;

       $key  = md5_hex ($key);
    my $keya = md5_hex (substr ($key, 0, 16));
    my $keyb = md5_hex (substr ($key, 16, 16));
#    my $keyc = random_string ('n' x $ckey_len); # substr (md5(microtime())) 不需要计算了 呵呵
    my $keyc = "1234";

    my $cryptkey   = $keya . md5_hex ($keya . $keyc);
    my $key_length = length ($cryptkey);

    my $string       = 0 x 10 . substr (md5_hex ($str . $keyb), 0, 16) . $str;
    my $string_lengh = length ($string);

    my (@rndkey, @box);
    for (0 .. 255)
    {
        push @box, $_;
        $rndkey[$_] = ord(substr ($cryptkey, $_ % $key_length, 1));
    }

    for (my ($i, $j) = (0, 0); $i < 256; ++ $i)
    {
        $j = ($j + $box[$i] + $rndkey[$i]) % 256;
        ($box[$i], $box[$j]) = ($box[$j], $box[$i]);
    }

    my $result;
    for ( my ($a, $i, $j) = (0, 0, 0); $i < $string_lengh; ++ $i)
    {
        $a = ($a + 1) % 256;
        $j = ($j + $box[$a]) % 256;
        ($box[$a], $box[$j]) = ($box[$j], $box[$a]);

        $result .= chr (ord (substr ($string, $i, 1)) ^ ($box[ ($box[$a] + $box[$j]) % 256 ] % 256));
    }

    ($result = $keyc . encode_base64 ($result)) =~ s/[\s=]//g;
    $result =~ s/\+/%2B/g;
    return $result;
}

1;

=head1 NAME

W3::UC - UCenter helper module

=head1 SYNOPSIS

use W3::UC qw/uc_encode/;

print uc_encode (..., ...);

=head1 DESCRIPTION

UCenter helper script

=head2 Methods

=over 12

=item C<new>

Returns a new W3::UC object.

=item C<uc_encode>

encode UC string with provided UC_KEY.

my $url_encoded = uc_encode ('time=999999999&action=updateapps', 'very_complicated_key');
say 'http://127.0.0.1/dzx3/uc/api.php?code=$url_encoded';

=back

=head1 AUTHOR

Aaron Lewis - <the.warl0ck.1989@gmail.com>

=cut

