#!/usr/bin/perl

####################################################
## Name    : lef.pm                               ##
## Synopsis: LEF file parser module               ##
## Author  : Ameer Abdelhadi                      ##
## Email   : aameer.abdelhadi@gmail.com           ##
####################################################

## add includes and modules to @INC
BEGIN{ push(@INC,"/hp/ameer/cgs/scr/pm"); }

use strict;	  # Install all strictures
use warnings;	  # Show warnings

package lef;
use vars '$VERSION';
$VERSION = '1.00';
use base 'Exporter';

use FileHandle;   # Use file handle, for dealing with files
use Getopt::Long; # For command line options (flags)
$|++;		  # Force auto flush of output buffer

## use graph visualization (GraphViz) module
use GraphViz;	  
use GraphViz::XML;

## use graph module
use Graph;
use Graph::Reader::XML;
use Graph::Writer::XML;
use Graph::Writer::Dot;
use Graph::Writer::GraphViz;

## use PostScript module
use PostScript::Simple;

## use Math::Polygon module
use Math::Polygon::Calc;
use Math::Polygon::Clip;
use Math::Polygon::Transform;

## use List add-ons module
use List::Util qw(max min);

our @EXPORT = qw/
	lefParse
/;

sub lefParse {

  my ($lefFileName)=@_;
  my %metals = ();
  
  open (NETHND,"<$lefFileName") || die "Cannot open ${lefFileName}. Program terminated!\n";
  my @lefLines=<NETHND>;
  chomp(@lefLines);
  my @metal;
  
  while (@lefLines) {
    my $lefLine=shift(@lefLines);

    ## remove comments and empty line
    if ($lefLine =~ /^\s*\/\//)  {next;}

   
    if ($lefLine =~ /^\s*LAYER\s*metal(\d*)\s*$/) {
      my $m=$1;
      my %curMetal;
      ## print ">> metal$m\n";
      $lefLine=shift(@lefLines);
      while ($lefLine !~ /^\s*END\s*metal$m\s*$/) {
	if ($lefLine =~ /^\s*(\S*)\s*(\S*)\s*\;\s*$/) {
	          ## print"-- $1 $2\n";
		  $curMetal{$1}=$2;
	}
	$metal[$m]=\%curMetal;
	$lefLine=shift(@lefLines);
      }
    }  
    
  }
  return \@metal;
  
}

#my $metalp=lefParse("/hp/ameer/cgs/lib/files/gscl45nm.lef");
#my @metal=@{$metalp};
#my $metal0p=$metal[0];
#my $m1w=$metalp->[2]{SPACING};
#print "--- $m1w\n";
