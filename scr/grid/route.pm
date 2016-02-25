#!/usr/bin/perl

####################################################
# Name:     route.pm                              ##
# Synopsis: Mesh routing module                   ##
# Authoe:   Ameer Abdelhadi                       ##
# Email:    ameer.abdelhadi@gmail.com             ##
####################################################

## add includes and modules to @INC
BEGIN{ push(@INC,"/hp/ameer/cgs/scr/pm"); }

use strict;	  # Install all strictures
use warnings;	  # Show warnings

package route;
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

use Term::ANSIColor qw(:constants);
#use POSIX qw(ceil floor);

## use List add-ons module
use List::Util qw(max min);

use lef;

our @EXPORT = qw/
	routeGrid
        initGrid
        fillGrid
        prnGrid
	getHorizontals
	getVerticals
	getVias
/;

sub floor  { return int($_[0] -  1 * ($_[0] <   0)); }
sub ceil   { return int($_[0] +  1 * ($_[0] >   0)); }
sub round  { return int($_[0] + .5 * ($_[0] <=> 0)); }
sub isOdd  { return (  $_[0] % 2) ; }
sub isEven { return (!($_[0] % 2)); }

#my $gridp=initGrid(20,15);
#fillGrid($gridp,4,4,12,12,3);
#fillGrid($gridp,9,9,14,14,1);
#fillGrid($gridp,14,0,20,6,1);

#prnGrid($gridp);

#getHorizontals($gridp);
#getVerticals($gridp);
#getVias($gridp);

my $metalp=lefParse("/hp/ameer/cgs/lib/files/gscl45nm.lef");

sub routeGrid {
  my ($corePolyp,$gridPolysp,$lowerMetal,$minSpace,$gridName,$SRouteFileName)=@_;
  my @corePoly =@{$corePolyp};
  my @gridPolys=@{$gridPolysp};
  
  # get core bounding box
  my $coreX0  =$corePoly[0][0];
  my $coreY0  =$corePoly[0][1];
  my $coreX1  =$corePoly[2][0];
  my $coreY1  =$corePoly[2][1];
  my $coreXdim=$coreX1-$coreX0;
  my $coreYdim=$coreY1-$coreY0;
  
  #Normalized values
  my $coreX0N  =ceil($coreX0/$minSpace);
  my $coreY0N  =ceil($coreY0/$minSpace);
  my $coreX1N  =ceil($coreX1/$minSpace);
  my $coreY1N  =ceil($coreY1/$minSpace);
  my $coreXdimN=ceil($coreXdim/$minSpace);
  my $coreYdimN=ceil($coreYdim/$minSpace);

  open (SROUTEHND,">$SRouteFileName") || die "Cannot write to $SRouteFileName. Program terminated!\n";
  print SROUTEHND <<END_OF_SROUTE;
Version 2.2
Micron 2000
9
M2_M1_via null M2 0 1 0 130 130 0 0 1 1 -65 -65 65 65 
1
-70 -135 70 135
1
-135 -65 135 65
M3_M2_via null M3 0 1 0 140 140 0 0 1 1 -70 -70 70 70 
1
-140 -70 140 70
1
-70 -140 70 140
M4_M3_via null M4 0 1 0 140 140 0 0 1 1 -70 -70 70 70 
1
-140 -140 140 140
1
-140 -70 140 70
M5_M4_via null M5 0 1 0 280 280 0 0 1 1 -140 -140 140 140 
1
-140 -140 140 140
1
-140 -140 140 140
M6_M5_via null M6 0 1 0 280 280 0 0 1 1 -140 -140 140 140 
1
-140 -140 140 140
1
-140 -140 140 140
M7_M6_via null M7 0 1 0 280 280 0 0 1 1 -140 -140 140 140 
1
-400 -400 400 400
1
-140 -140 140 140
M8_M7_via null M8 0 1 0 800 800 0 0 1 1 -400 -400 400 400 
1
-400 -400 400 400
1
-400 -400 400 400
M9_M8_via null M9 0 1 0 800 800 0 0 1 1 -400 -400 400 400 
1
-800 -800 800 800
1
-400 -400 400 400
M10_M9_via null M10 0 1 0 1600 1600 0 0 1 1 -800 -800 800 800 
1
-800 -800 800 800
1
-800 -800 800 800
END_OF_SROUTE

  print "initGrid($coreXdimN,$coreYdimN)\n";
  my $gridp=initGrid($coreXdimN,$coreYdimN);
  
  print"$coreXdim $coreYdim $coreXdimN $coreYdimN $minSpace\n";

  foreach my $phasePolys (reverse(@gridPolys)) {

    my $phaseDensity  =shift(@{$phasePolys});
    my $phaseSkew     =shift(@{$phasePolys});
  
    #### print "Phase... $phaseSkew $phaseDensity\n";
  
    foreach my $polyp (@{$phasePolys}) {
    
      my @poly=@{$polyp};
    
      # get core bounding box
      my $polyX0  =$poly[0][0];
      my $polyY0  =$poly[0][1];
      my $polyX1  =$poly[2][0];
      my $polyY1  =$poly[2][1];
  
      #Normalized values
      my $polyX0N  =round(($polyX0-$coreX0)/$minSpace);
      my $polyY0N  =round(($polyY0-$coreY0)/$minSpace);
      my $polyX1N  =round(($polyX1-$coreX0)/$minSpace);
      my $polyY1N  =round(($polyY1-$coreY0)/$minSpace);
      
      #my $pitch=floor($phaseDensity/3);
      my $pitch=round((($phaseDensity/10)-int($phaseDensity/10)+1)*20);
      print "fillGrid($gridp,$polyX0N,$polyY0N,$polyX1N,$polyY1N,$pitch $phaseDensity $phaseSkew)\n";
      fillGrid($gridp,$polyX0N,$polyY0N+1,$polyX1N,$polyY1N,$pitch);
        
    }
  }

  prnGrid($gridp);
  my $horizontalsp=getHorizontals($gridp,$coreX0,$coreY0,$lowerMetal,$minSpace,2000);
  my $verticalsp=getVerticals($gridp,$coreX0,$coreY0,$lowerMetal,$minSpace,2000);
  my $viasp=getVias($gridp,$coreX0,$coreY0,$lowerMetal,$minSpace,2000);
  my @verticals=@{$verticalsp};
  my @horizontals=@{$horizontalsp};
  my @vias=@{$viasp};
  my $wiresn=scalar(@verticals)+scalar(@horizontals);
  my $viasn=scalar(@vias);
  print SROUTEHND "$wiresn $viasn 1 $gridName\n";
  foreach my $vertical (@verticals) {
    print SROUTEHND "$vertical\n";
  }
  foreach my $horizontal (@horizontals) {
    print SROUTEHND "$horizontal\n";
  }
  foreach my $via (@vias) {
    print SROUTEHND "$via\n";
  }
  
}

sub initGrid {
  my ($xdim,$ydim)=@_;
  my %grid;
  my @xmat;
  my @ymat;
  $grid{xdim}=$xdim;
  $grid{ydim}=$ydim;
  $grid{xmatp}=\@xmat;
  $grid{ymatp}=\@ymat;
  for (my $yi=0; $yi<=$ydim; $yi++) {
    for (my $xi=0; $xi<=$xdim; $xi++) {
#      if ($xi!=$xdim) {$xmat[$xi][$yi]=0};
#      if ($yi!=$ydim) {$ymat[$xi][$yi]=0};
      $xmat[$xi][$yi]=0;
      $ymat[$xi][$yi]=0;      
    }
  }
   return \%grid;
}

sub prnGrid {
  my $gridp=$_[0];
  my $xdim=$gridp->{xdim};
  my $ydim=$gridp->{ydim};
  my $xmatp=$gridp->{xmatp};
  my $ymatp=$gridp->{ymatp};
  for (my $yi=$ydim; $yi>=0; $yi--) {

    for (my $xi=0; $xi<=$xdim; $xi++) {
      if ($yi!=$ydim) {
        if ($ymatp->[$xi][$yi]) {print "|  ";}
	else                    {print ":  ";}
      }
    }
    print "\n";


    for (my $xi=0; $xi<$xdim; $xi++) {
      if ($xmatp->[$xi][$yi]) {print " --";}
      else                    {print " ..";} 
    }
    print "\n";
    
  }
}

sub fillClean {
  my ($gridp,$x1,$y1,$x2,$y2)=@_;
  my $xdim=$gridp->{xdim};
  my $ydim=$gridp->{ydim};
  my $xmatp=$gridp->{xmatp};
  my $ymatp=$gridp->{ymatp};
  
  for (my $yi=$y1; $yi<=$y2; $yi++) {
    for (my $xi=$x1; $xi<=$x2; $xi++) {
      if ($xi!=$x2) {$xmatp->[$xi][$yi]=0};
      if ($yi!=$y2) {$ymatp->[$xi][$yi]=0};
    }
  }
  
#  for (my $yi=$y1; $yi<=$y2; $yi++) {
#    for (my $xi=$x1; $xi<$x2; $xi++) {
#      $xmatp->[$xi][$yi]=0;
#    }
#  }
#  for (my $yi=$y1; $yi<$y2; $yi++) {
#    for (my $xi=$x1; $xi<=$x2; $xi++) {
#      $ymatp->[$xi][$yi]=0;
#    }
#  }  
  
}

sub fillContour {
  my ($gridp,$x1,$y1,$x2,$y2)=@_;
  my $xdim=$gridp->{xdim};
  my $ydim=$gridp->{ydim};
  my $xmatp=$gridp->{xmatp};
  my $ymatp=$gridp->{ymatp};
  for (my $xi=$x1; $xi<$x2; $xi++) {
    $xmatp->[$xi][$y1]=1;
    $xmatp->[$xi][$y2]=1;
  }
  for (my $yi=$y1; $yi<$y2; $yi++) {
    $ymatp->[$x1][$yi]=1;
    $ymatp->[$x2][$yi]=1;
  }
}

sub fillInternal {
  my ($gridp,$x1,$y1,$x2,$y2,$density)=@_;
  my $xdim=$gridp->{xdim};
  my $ydim=$gridp->{ydim};
  my $xmatp=$gridp->{xmatp};
  my $ymatp=$gridp->{ymatp};
  for (my $yi=($y1+$density); $yi<$y2; $yi+=$density) {
    for (my $xi=$x1; $xi<$x2; $xi++) {
      $xmatp->[$xi][$yi]=1;
    }
  }
  for (my $yi=$y1; $yi<$y2; $yi++) {
    for (my $xi=($x1+$density); $xi<$x2; $xi+=$density) {
      $ymatp->[$xi][$yi]=1;
    }
  }
}

sub fillGrid {
  my ($gridp,$x1,$y1,$x2,$y2,$density)=@_;
  fillClean   ($gridp,$x1,$y1,$x2,$y2);
  fillInternal($gridp,$x1,$y1,$x2,$y2,$density);
  fillContour ($gridp,$x1,$y1,$x2,$y2);
}

sub getVerticals {
  my ($gridp,$x0,$y0,$lowerMetal,$space,$scale)=@_;
  my @verticals;
  my $xdim=$gridp->{xdim};
  my $ydim=$gridp->{ydim};
  my $xmatp=$gridp->{xmatp};
  my $ymatp=$gridp->{ymatp};
  
  my $VMetal=$lowerMetal; my $HMetal=$lowerMetal;
  if ($metalp->[$lowerMetal]{DIRECTION} eq "HORIZONTAL") {$VMetal++} else {$HMetal++};
  my $VMetalWidth=$metalp->[$VMetal]{WIDTH}*$scale;
  my $HMetalWidth=$metalp->[$HMetal]{WIDTH}*$scale;
  
  for (my $xi=0; $xi<=$xdim; $xi++) {
    my $prev=0;
    my ($y0_,$y1_,$x0_,$length);
    for (my $yi=0; $yi<=$ydim; $yi++) {
      my $xi0=round((($xi*$space)+$x0)*$scale);
      my $yi0=round((($yi*$space)+$y0)*$scale);    
      ## opening edge
      if    (  ( $ymatp->[$xi][$yi])                && (!$prev)) {$x0_=$xi0;$y0_=$yi0;}
      ## closing edge
      elsif ( ((!$ymatp->[$xi][$yi])||($yi==$ydim)) && ( $prev)) {
	$y1_=$yi0;
	$length=$y1_-$y0_+$HMetalWidth;
	push(@verticals,"$x0_ $y0_ $VMetalWidth $length M$VMetal 010 0 1");
      }
      $prev=$ymatp->[$xi][$yi];
    }
  }
  return \@verticals;
}

sub getHorizontals {
  my ($gridp,$x0,$y0,$lowerMetal,$space,$scale)=@_;
  my @horizontals;
  my $xdim=$gridp->{xdim};
  my $ydim=$gridp->{ydim};
  my $xmatp=$gridp->{xmatp};
  my $ymatp=$gridp->{ymatp};

  my $VMetal=$lowerMetal; my $HMetal=$lowerMetal;
  if ($metalp->[$lowerMetal]{DIRECTION} eq "HORIZONTAL") {$VMetal++} else {$HMetal++};
  my $VMetalWidth=$metalp->[$VMetal]{WIDTH}*$scale;
  my $HMetalWidth=$metalp->[$HMetal]{WIDTH}*$scale;
  
  for (my $yi=0; $yi<=$ydim; $yi++) {
    my $prev=0;
    my ($x0_,$x1_,$y0_,$length);
    for (my $xi=0; $xi<=$xdim; $xi++) {
      my $xi0=round((($xi*$space)+$x0)*$scale);
      my $yi0=round((($yi*$space)+$y0)*$scale);
      ## opening edge
      if    (  ( $xmatp->[$xi][$yi])                && (!$prev)) {$y0_=$yi0;$x0_=$xi0;}
      ## closing edge
      elsif ( ((!$xmatp->[$xi][$yi])||($xi==$xdim)) && ( $prev)) {
        $x1_=$xi0;
	$length=$x1_-$x0_+$VMetalWidth;
	push(@horizontals,"$x0_ $y0_ $length $HMetalWidth M$HMetal 100 0 1");
      }
      $prev=$xmatp->[$xi][$yi];
    }
  }
  return \@horizontals;
}

sub getVias {
  my ($gridp,$x0,$y0,$lowerMetal,$space,$scale)=@_;
  my @vias;
  my $xdim=$gridp->{xdim};
  my $ydim=$gridp->{ydim};
  my $xmatp=$gridp->{xmatp};
  my $ymatp=$gridp->{ymatp};
  
  my $via=$lowerMetal-1;
  my $VMetal=$lowerMetal; my $HMetal=$lowerMetal;
  if ($metalp->[$lowerMetal]{DIRECTION} eq "HORIZONTAL") {$VMetal++} else {$HMetal++};
  my $VMetalWidth=$metalp->[$VMetal]{WIDTH}*$scale;
  my $HMetalWidth=$metalp->[$HMetal]{WIDTH}*$scale;
  
  for (my $yi=0; $yi<=$ydim; $yi++) {
    for (my $xi=0; $xi<=$xdim; $xi++) {
      my $xi0=($xi*$space+$x0)*$scale;
      my $yi0=($yi*$space+$y0)*$scale;
      if ($lowerMetal==1) {$xi0-=$HMetalWidth/2; $yi0-=$VMetalWidth/2;}
      if ($lowerMetal==2) {$xi0-=$VMetalWidth/2; $yi0-=$HMetalWidth/2;}
      if ($lowerMetal==3) {$yi0-=$HMetalWidth/2;                      }
      if ($lowerMetal==6) {$xi0-=0.130*$scale  ;                      }
      if ($lowerMetal==8) {$xi0-=$VMetalWidth/2;                      }
      $xi0=round($xi0);
      $yi0=round($yi0);
      if ( ($xmatp->[$xi][$yi] || $xmatp->[$xi-1][$yi]) &&
           ($ymatp->[$xi][$yi] || $ymatp->[$xi][$yi-1]) ) {
        push(@vias,"$xi0 $yi0 $via 0 0 1");
      }   
    }
  }
  
  return \@vias;
}
