#!/usr/bin/perl
use strict;
use warnings;

package JSONParser;
use Carp qw/croak/;
use File::Slurp qw/read_file write_file/;
use JSON qw/from_json to_json/;
sub new {
  my $class = shift;
  my %args = @_;
  croak "No 'input' file arguement provided"
    unless(defined $args{input});
  croak "File $args{input} not readable"
    unless(-r $args{input});
  my $self = {
    data => from_json(
      read_file(
        $args{input}
      )
    )
  };
  bless $self, $class;
  return $self;
}
# Keys must be non-empty strings and can't contain ".", "#", "$", "/", "[", or "]"
sub slugify {
  my $self = shift;
  my $text = shift;
  return unless defined $text;
  $text =~ s|[.#$/\[\]]||g;
  return $text;
}
sub slugify_keys {
  my $self = shift;
  my $next = shift;
  my $reftype = ref $next;
  # nothing
  if(!defined $next){
    return;
  }
  # no ref
  elsif(!$reftype || $reftype eq 'JSON::PP::Boolean'){
    return $next;
  }
  # hash ref
  elsif($reftype eq 'HASH'){
    my $new_ref = {};
    for my $key(keys %{$next}){
      my $value = $next->{$key};
      $new_ref->{$self->slugify($key)} =
        $self->slugify_keys($value);
    }
    return $new_ref;
  }
  # array ref
  elsif($reftype eq 'ARRAY'){
    my $new_ref = [];
    for my $i (0..(scalar(@$next) - 1)){
      $new_ref->[$i] = $self->slugify_keys($next->[$i]);
    }
    return $new_ref;
  }
  else {
    require Data::Dumper;
    croak "Unsupported reftype '$reftype' provided for ".Data::Dumper->Dumper($next);
  }
}
sub slugify_data {
  my $self = shift;
  $self->{data} = $self->slugify_keys($self->{data});
}
sub print_data {
  my $self = shift;
  my $location = shift;
  my $json_string = to_json($self->{data});
  if(!defined $location){
    print STDERR "No location provided, using STDOUT\n";
    print $json_string, "\n";
  }
  else {
    write_file($location, $json_string) or die "Write to $location failed!";
  }
}

package default;
use Log::Log4perl qw/:easy/;
Log::Log4perl->easy_init($DEBUG);

INFO "Script start";
my $parser = JSONParser->new(input => $ARGV[0]);
$parser->slugify_data();
$parser->print_data($ARGV[1]);
INFO "Script finished";

