#!/usr/bin/perl 
use strict;
use warnings;

use TeX::Hyphen;
use List::Util 'max';


our $hyp;
if ( -e "hyphen.tex") {
$hyp = new TeX::Hyphen file=>"hyphen.tex";
} else {
$hyp = new TeX::Hyphen ;
}
sub buttify {
   my (@words) = (@_);
   my $rep = int(@words/11)+1;
   my $c =0;

   # sort indicies by word length
   my @longest=  map { $_->[0] }
                sort { $b->[1] <=> $a->[1] }
                map { [$c++ , length($_) ] } @words;
   $c=0;

   # remove stop words
   @longest = grep {$words[$_] !~/^(a|an|and|or|but|it|in|its|It's|it's|the|of|you|I|i)$/} @longest;
   # print "Words in order: ".join(",",map {$words[$_]} @longest)."\n";

   # create weighed index array of words by length
   my @index= map {$longest[$_]} weighed_index_array(scalar @longest);
   #print "Weighed words in order: ".join(",",map {$words[$_]} @index)."\n";

   shuffle(\@index) if (scalar @index);
   while ($c < $rep) {
        $words[$index[$c]]=&buttsub($words[$index[$c]]);
        $c++;
  }

  return @words;
}

sub buttifynew {
   my (@words) = (@_);
   my $rep = int(@words/11)+1;
   my $c =0;

   # create list of weights and sort them.

   my $factor = max(map {length($_)} @words);

   # print "Factor : $factor \n"; 
   # sort indicies by word length
   
   my @pairs = map { [$c++,length($_)] } @words;
  
   #print "Pairs: ".join(",",map{$_->[0]." ".$_->[1]}@pairs)."\n";

   @pairs = grep {$words[$_->[0]] !~/^(a|an|and|or|but|it|in|the|of|you|I|i)$/} @pairs;

   #print "Stripped Pairs: ".join(",",map{$_->[0]." ".$_->[1]}@pairs)."\n";
  
   #@pairs = map { [$_->[0], rand($factor**$_->[1])**(1.0/$_->[1])]} @pairs;  
   @pairs = map { [$_->[0], rand($_->[1]**$factor)**(1.0/$factor)]} @pairs;  
   #@pairs = map { [$_->[0], log(rand(exp($_->[1]))+1)]} @pairs;  

   #print "Weighed Pairs: ".join(",",map{$_->[0]." ".$_->[1]}@pairs)."\n";

   @pairs = sort { $b->[1] <=> $a->[1]} @pairs;  
   
   #print "Sorted Pairs: ".join(",",map{$_->[0]." ".$_->[1]}@pairs)."\n";
   
   my @index = map { $_->[0]} @pairs;
   
   $c=0;
   
   # remove stop words

   while ($c < $rep) {
        $words[$index[$c]]=&buttsub($words[$index[$c]]);
        $c++;
  }

  return @words;
}


sub buttsub {
   my $word = shift @_;
   
   my @points = $hyp->hyphenate($word);
   unshift(@points,0);

   my $factor = 2;
   my $len = scalar @points;
   my $replace = $len -1 - int(rand($len ** $factor) ** (1.0/$factor));
   push @points,length($word);

   my $l = $points[$replace];
   my $r = $points[$replace+1]- $l ;
   while (substr($word,$l+$r,1) eq "t") { $r++; }
   my $sub = substr($word,$l,$r);
   my $butt ="butt";

   if ($sub eq uc $sub) {
     $butt = "BUTT";
   } elsif ($sub =~/^[A-Z]/) {
     $butt = "Butt";
   } 
   substr($word,$l,$r) = $butt;
   return $word;
}

## perl cookbook
# fisher_yates_shuffle( \@array ) : generate a random permutation
# of @array in place
sub shuffle {
    my $array = shift;
    my $i;
    for ($i = @$array; --$i; ) {
        my $j = int rand ($i+1);
        next if $i == $j;
        @$array[$i,$j] = @$array[$j,$i];
    }
}

sub weighed_index_array {
	my $len = shift;
        my $c = 0;
        my $n = $len;
        my @a = ();
        while ($c < $len) {
           push @a, ($c) x ($n*$n);
           $n--;
           $c++;
        }
	return @a;
}

1;
