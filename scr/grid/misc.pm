#!/usr/bin/perl

####################################################
# Name:     misc.pm                               ##
# Synopsis: Miscellaneous functions module        ##
# Authoe:   Ameer Abdelhadi                       ##
# Email:    ameer.abdelhadi@gmail.com             ##
####################################################

BEGIN{ push(@INC,"/hp/ameer/cgs/scr/pm"); }

use strict;	  # Install all strictures
use warnings;	  # Show warnings


package misc;
use vars '$VERSION';
$VERSION = '1.00';
use base 'Exporter';



use FileHandle;   # Use file handle, for dealing with files
use Getopt::Long; # For command line options (flags)
$|++;		  # Force auto flush of output buffer

use GraphViz;	  # Use graph visualization module
use GraphViz::XML;

use Graph;
use Graph::Reader::XML;
use Graph::Writer::XML;
use Graph::Writer::Dot;
use Graph::Writer::GraphViz;

use PostScript::Simple;

use Math::Polygon::Calc;
use Math::Polygon::Clip;
use Math::Polygon::Transform;

use List::Util qw(max min);

our @EXPORT = qw/
	poly2grid
	segments2eps
	segmentsMove
/;



my $Inf;
BEGIN {
    local $SIG{FPE}; 
    eval { $Inf = exp(999) } ||
        eval { $Inf = 9**9**9 } ||
            eval { $Inf = 1e+999 } ||
                { $Inf = 1e+99 };  # Close enough for most practical purposes.
}
sub Infinity () { $Inf }


sub _B () { 0 } # Begin.
sub _E () { 1 } # End.
sub _D () { 2 } #
sub _X () { 0 } # Begin.
sub _Y () { 1 } # End.

sub intervalPiontInside	{my ($p,$i)=@_; return ( ($p>=($i->[_B])) && ($p<=($i->[_E])) ) }
sub intervalHardLeft	{my ($a,$b)=@_; return (($a->[_E])<($b->[_B])) }
sub intervalSoftLeft	{my ($a,$b)=@_; return ( (($a->[_B])<($b->[_B]))  && (($a->[_E])>=($b->[_B])) && (($a->[_E])<($b->[_E])) ) }
sub intervalContain	{my ($a,$b)=@_; return ( (($a->[_E])>=($b->[_E])) && (($a->[_B])<=($b->[_B])) ) }
sub intervalIntersect	{my ($a,$b)=@_; return (intervalPiontInside($a->[_B],$b)) || (intervalPiontInside($a->[_E],$b)) || (intervalPiontInside($b->[_B],$a))  }

sub intervalAdd {
	my ($newP,@intervals)=@_;

	if (!scalar(@intervals)) { return ($newP) }

	my $fstP=shift(@intervals);	

	if (intervalHardLeft($newP,$fstP)) { return ($newP,$fstP,@intervals) }
	if (intervalHardLeft($fstP,$newP)) { return ($fstP,intervalAdd($newP,@intervals)) }
	return (intervalAdd( [min($newP->[_B],$fstP->[_B]),max($newP->[_E],$fstP->[_E])],@intervals) );
}
sub intervalRem {
	my ($remP,@intervals)=@_;
	my @newIntervals;
	foreach my $inter (@intervals) {
		if (intervalIntersect($remP,$inter)) {
			if (intervalContain($remP,$inter)) {next;}
			if (intervalContain($inter,$remP)) {
				if ($remP->[_B] > $inter->[_B]) {push(@newIntervals,([$inter->[_B],$remP->[_B]]))}
				if ($inter->[_E] > $remP->[_E]) {push(@newIntervals,([$remP->[_E],$inter->[_E]]))}
				next;
			}
			if ($remP->[_B] < $inter->[_B]) {
				push(@newIntervals,([$remP->[_E],$inter->[_E]]));
			} else {
				push(@newIntervals,([$inter->[_B],$remP->[_B]]));
			}
		} else {
			push(@newIntervals, $inter)
		}
	}
	return @newIntervals;
}

sub polygon2segments {
	my ($dir,@poly)=@_;
	my $i1;
	my $i2;
	my @Segments;
	
	my $offset;
	my $edges ;
	
	my $dirN = ($dir eq "X") ? _Y : _X;

	for ($i1 = 0 ; $i1 < scalar(@poly) ; $i1++) {
		$i2 = cyclicAdd($i1,0,$#poly);
		my $point1=$poly[$i1];
		my $point2=$poly[$i2];
		
		if ($point1->[$dirN] == $point2->[$dirN]) { 
			push (@Segments,[$point1,$point2]);
		}
		
	}
	return @Segments;
}
sub interval2segments {
	my ($dir,$offset,@interval)=@_;
	my @segments = ($dir eq "X") ?
			map {[[$_->[_B],$offset],[$_->[_E],$offset]]} @interval :
			map {[[$offset,$_->[_B]],[$offset,$_->[_E]]]} @interval ;
	return @segments;
}

sub point2string {
	my $point=$_[0];
	return "($point->[_X],$point->[_Y])";
}
sub segment2string {
	my $seg=$_[0];
	my $point1s=point2string($seg->[_B]);
	my $point2s=point2string($seg->[_E]);
	return "[$point1s,$point2s]";
}
sub segments2string {
	my @segs = @_ ;
	my @segmentsString;
	foreach my $seg (@segs) {push(@segmentsString,segment2string($seg))}
	return join ',' , @segmentsString;
}

sub poly2grid {
	my ($pitch,$dir,@poly)=@_;
	
	my ($minx,$miny,$maxx,$maxy)=polygon_bbox(@poly);
	my $min = ($dir eq "X") ? $miny : $minx;
	my $max = ($dir eq "X") ? $maxy : $maxx;
		
	my @polySegments = polygon2segments($dir,@poly);

	my @addedSegments ;
	for (my $offset = $min ; $offset <= $max ; $offset+=$pitch) {
		my $addedSegment = ($dir eq "X") ? [[undef,$offset],[undef,$offset]] : [[$offset,undef],[$offset,undef]];
		push(@addedSegments,$addedSegment) ;
	}
	
	my @allSegments = (@polySegments,@addedSegments) ;
	my @sortedSegments =($dir eq "X") ? sort {$a->[_B]->[_Y] <=> $b->[_B]->[_Y]} @allSegments : sort {$a->[_B]->[_X] <=> $b->[_B]->[_X]} @allSegments;
	
	my @cur_inter;
	my @gridSegments;
	foreach my $seg (@sortedSegments) {
		my @newsegs;
		my $newsegsString;
		if (!(defined $seg->[_B]->[_X])) {
				@newsegs = interval2segments("X",$seg->[_B]->[_Y],@cur_inter);
				#$newsegsString = segments2string(@newsegs);
				#print "$newsegsString\n";
				push(@gridSegments,@newsegs);
		} elsif (!(defined $seg->[_B]->[_Y])) {
				@newsegs = interval2segments("Y",$seg->[_B]->[_X],@cur_inter);
				#$newsegsString = segments2string(@newsegs);
				#print "$newsegsString\n";
				push(@gridSegments,@newsegs);
		} else {
			if ($dir eq "Y") {
				if ($seg->[_B]->[_Y] > $seg->[_E]->[_Y]) { ## openning
					@cur_inter=intervalAdd( [$seg->[_E]->[_Y] , $seg->[_B]->[_Y] ],@cur_inter);
				} else { ##closing
					@cur_inter=intervalRem( [$seg->[_B]->[_Y] , $seg->[_E]->[_Y] ],@cur_inter);
				}
			} else {
				if ($seg->[_E]->[_X] > $seg->[_B]->[_X] ) { ## openning
					@cur_inter=intervalAdd( [$seg->[_B]->[_X] , $seg->[_E]->[_X] ],@cur_inter);
				} else { ##closing
					@cur_inter=intervalRem( [$seg->[_E]->[_X] , $seg->[_B]->[_X] ],@cur_inter);
				}			
			}
		}
	}
	return @gridSegments;
}

sub segments2eps {
	my ($eps,@segs)=@_;
	foreach my $seg (@segs) {
		$eps->line($seg->[_B]->[_X],$seg->[_B]->[_Y],$seg->[_E]->[_X],$seg->[_E]->[_Y]);
	}
}

sub segmentsMove()
{   my %opts;
    while(@_ && !ref $_[0])
    {   my $key     = shift;
        $opts{$key} = shift;
    }

    my ($dx, $dy) = ($opts{dx}||0, $opts{dy}||0);
    return @_ if $dx==0 && $dy==0;

    map { [ [ $_->[_B]->[_X] + $dx, $_->[_B]->[_Y] + $dy ] , [ $_->[_E]->[_X] + $dx, $_->[_E]->[_Y] + $dy ] ] } @_;
}


sub polygonMinMax {
	my  @poly=@_;
	my $min=    Infinity  ;
	my $max=(-1*Infinity) ;
	foreach my $point (@poly) {
	
	}
}

sub cyclicAdd {
	my ($num,$min,$max)=@_;
	if ($num == $max) {return $min}
	return $num+1;
}
sub cyclicSub {
	my ($num,$min,$max)=@_;
	if ($num == $min) {return $max}
	return $num-1;
}
