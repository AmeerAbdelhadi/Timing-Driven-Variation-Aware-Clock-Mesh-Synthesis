#!/usr/bin/perl

####################################################
## Name    : grid.pl                              ##
## Synopsis: Clock grid (mesh) generator          ##
## Author  : Ameer Abdelhadi                      ##
## Email   : aameer.abdelhadi@gmail.com           ##
####################################################

## add includes and modules to @INC
BEGIN{ push(@INC,"/hp/ameer/cgs/scr/pm"); }

use strict;	  # Install all strictures
use warnings;	  # Show warnings
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

use route;

#my $gridp=initGrid(20,15);
#fillGrid($gridp,4,4,12,12,3);
#fillGrid($gridp,9,9,14,14,1);
#fillGrid($gridp,14,0,20,6,1);
#
#prnGrid($gridp);

#getHorizontals($gridp);
#getVerticals($gridp);
#getVias($gridp);


my %options=();
if ( ! &GetOptions (
  "tcgxml|tcg|xml:s"  =>\$options{tcgxml},
  "lookuptable|lup:s" =>\$options{lookuptable},
  "weights|w:s"       =>\$options{weights},
  "lowermetal|lm:s"   =>\$options{lowermetal},
  "drawin|di:s"       =>\$options{drawin},
  "drawout|do:s"      =>\$options{drawout},
  "drawgraph|dg:s"    =>\$options{drawgraph},
  "h|help"            =>\$options{help}
) || $options{help} || (!$options{tcgxml}) || ( 0 && !defined($options{drawin}) && !defined($options{drawout}) ) ) {
print STDOUT <<END_OF_HELP;
SYNOPSIS:
  Generate clock grid
USAGE:
  grid.pl -xml <xml>
PARAMETERS:
  -tcgxml|tcg|xml  <xml>: input verilog netlist file
  -lookuptable|lup <lup>: skew/grid density lookup table
  -weights|w            : grid weights
  -drawin |di      <png>: draw input netlist graph into <png file> 
  -drawout|do      <png>: draw output netlist graph into <png file> 
  -drawgraph|dg    <png>:
  -help|h: print this massege 
  > (-tcgxml) and at least one of (-lup) or (-weights) are required
EXAMPLE:
  grid.pl -xml s27.xml -di -do -dg -w "0.5 0.51 0.52 0.53 0.54 0.55"
  grid.pl -xml s208_1.xml -di -do -dg -w "0.2 0.25 0.3 0.35 0.4"
  grid.pl -xml s349.xml -di -do -dg -w "0.1 0.15 0.2 0.25"
  grid.pl -xml s382.xml -di -do -dg -w "0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5"
  grid.pl -xml s838_1.xml -di -do -dg -w "0 0.01 0.02 0.03 0.03 0.05 0.06 0.07 0.08 0.09 0.1 1.1"
  grid.pl -xml s1423.xml -di -do -w "\-0.7 \-0.6 \-0.5 \-0.4 \-0.3 \-0.2 \-0.1 0 0.1 0.2 0.3 0.4 0.5"
REPORT BUGS:
  Ameer Abdel-hadi (ameer.abdelhadi\@gmail.com)
END_OF_HELP
exit;
}
#######################################################

## parse lookuptable file
my %LUPHash;
if (defined($options{lookuptable})) {
  open (LUPHND,"<$options{lookuptable}") || die "Cannot open $options{lookuptable}. Program terminated!\n";
  my @LUPLines=<LUPHND>;
  chomp(@LUPLines);
  foreach my $lupline (@LUPLines) {
    ## remove comments and empty line
    if (($lupline =~ /^\s*\#/) || ($lupline =~ /^\s*$/))  {next;}
    ## need two pairs of floating point numbers
    ## [-+]?(\d*\.\d+|\d+) is floating point number regular expression
    if  ($lupline =~ /^\s*([-+]?(\d*\.\d+|\d+))\s+([-+]?(\d*\.\d+|\d+))\s*$/)  { $LUPHash{$1}=$3;}
      else {die "Lookup table file: $options{lookuptable} syntax error\n";}
  }

  #foreach my $lupkey (sort(keys %LUPHash)) {
  #  print "$lupkey-->$LUPHash{$lupkey}\n";
  #}

  
}


#######################################################


my $xml_fn=$options{tcgxml};
    
my $reader = Graph::Reader::XML->new();
my $g      = $reader->read_graph($xml_fn);
removeSelfLoop($g);
set_vertices_attribute("leaf",1,$g->vertices);

my $sg = $g->deep_copy_graph;

my $wr_png = Graph::Writer::GraphViz->new(-format => 'png');

####################################################################

my @corepoly = text2poly($g->get_graph_attribute("polygon")) ;
my $eps = new PostScript::Simple(xsize => ($corepoly[2][0]-$corepoly[0][0]),
                                ysize => ($corepoly[2][1]-$corepoly[0][1]),
                                colour => 1,
                                eps => 1,
                                reencode => undef,
				units => "in",);
grp2eps($eps,$g);

if (defined($options{drawin})) {
  my $epsInFN = $options{drawin} ? "$options{drawin}" : "$options{tcgxml}.in";
  $eps->output("$epsInFN.eps");
  system("eps2png.pl","$epsInFN.eps");
  system("/bin/rm","-f","$epsInFN.eps");
}

#############################################################

#my @GridPolys = getGridPolys($g,(-1,-0.9,-0.8,-0.7,-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2));
#my @GridPolys = getGridPolys($g,(0,0.01,0.02,0.03,0.03,0.05,0.06,0.07,0.08,0.09,0.1,1.1));

###$options{weights} =~ s/\\//g;
###my @GridPolys = getGridPolys($g,split(/\s+/,$options{weights}));

my @GridPolys = getGridPolys($g,(sort(keys %LUPHash)));
#############################################################

my @colours=qw(
		255 255 0
		255 0 255
		0 255 255
		200 200 0
		200 0 200
		0 200 200
		128 128 0
		128 0 128
		0 128 128
		200 200 200
		128 128 128
		255 128 0
		255 0 128
		128 255 0
		128 0 255
		0 128 255
		0 255 128
		176 23 31
		220 20 60
		255 182 193
		139 95 101
		255 240 245
		218 112 214
		139 71 137
		155 48 255
		198 113 113
		142 142 56
		113 198 113
);



##############
my $minSpace=0.2;
my $lowerMetal=$options{lowermetal};
my $SRouteFileName="grid.sroute";
routeGrid(\@corepoly,\@GridPolys,$lowerMetal,$minSpace,"clk_mesh_drive_L01_N0",$SRouteFileName);
##############

my $corepolyString=polygon_string(@corepoly);
print "Core: $corepolyString\n";

foreach my $phasePolys (reverse(@GridPolys)) {

  #my $phaseDensity  =shift(@{$phasePolys});
  #my $phaseSkew     =shift(@{$phasePolys});
  
  #print "Phase... $phaseSkew $phaseDensity\n";
  
  foreach my $poly (@{$phasePolys}) {
    my @polyMove = polygon_move( dx=>((-1)*$corepoly[0][0]),dy=>((-1)*$corepoly[0][1]),@{$poly});
    my $polyString=polygon_string(@{$poly});
    my $polyMoveString=polygon_string(@polyMove);
    
    print "Poly: $polyString\n";
    print "Move: $polyMoveString\n";
    
    $eps->setcolour(shift(@colours),shift(@colours),shift(@colours));
    $eps->polygon({filled=>1},poly2list(@polyMove));
    
  }
}

if (defined($options{drawout})) {
  my $epsOutFN = $options{drawout} ? "$options{drawout}" : "$options{tcgxml}.out";
  $eps->output("$epsOutFN.eps");
  system("eps2png.pl","$epsOutFN.eps");
  system("/bin/rm","-f","$epsOutFN.eps");
}

#############################################################
sub getGridPolys {
  my ($g,@smoothList)=@_;
  my @corepoly = text2poly($g->get_graph_attribute("polygon")) ;
  my @gridPolys;
  my $phaseNum = 0;
  while ( (scalar($g->vertices)>1) && (scalar(@smoothList)>0) ) {
    my $xxx=scalar($g->vertices);
    print "-- Phase: $phaseNum : ($xxx)\n";

    if (defined($options{drawgraph})) {
      my $grpFN = $options{drawgraph} ? "$options{drawgraph}" : "$options{tcgxml}.$phaseNum";    
      print ">> Drawing graph to $grpFN...\n";
      $wr_png->write_graph($g,"$grpFN");
    }

    my $gg = $g->deep_copy_graph;
    my $phaseSkew=shift(@smoothList);
    SmoothTCG($gg,$phaseSkew);

    my @wcc = $gg->weakly_connected_components();
    my $i=0;
    my @phasePolys;
    foreach my $wcp (@wcc) {
  
      if (scalar(@{$wcp}) > 1) {
          
        my @wc=@{$wcp};
        my @vbbox=vertices_bbox($gg,@wc);
        my @vbboxmov = polygon_move( dx=>((-1)*$corepoly[0][0]),dy=>((-1)*$corepoly[0][1]),@vbbox);
        #$eps->polygon({filled=>1},poly2list(@vbboxmov));
  
        push(@phasePolys,\@vbbox);
  

        print "  -- Component: $i\n";
        my $newVertex="phase${phaseNum}_component${i}";
        mergeVertices($g,$newVertex,@wc);
        removeSelfLoop($g);
        my @vbboxList = poly2list(@vbbox);
        $g->set_vertex_attribute($newVertex,"polygon","@vbboxList");
        vertexUpdateLabel($g,$newVertex);
        $i++;
      }
    
    }
    ##if (scalar(@phasePolys)>0) {push(@gridPolys,\@phasePolys)}
    if (scalar(@phasePolys)>0) {
      unshift(@phasePolys,$phaseSkew);
      unshift(@phasePolys,$LUPHash{$phaseSkew});
      push(@gridPolys,\@phasePolys)
    }
  
    $phaseNum++;
    
  }

  ## print ">> Drawing graph to $xml_fn.$phaseNum.png...\n";
  ## $wr_png->write_graph($g,"$xml_fn.$phaseNum.png");
 
  return @gridPolys;

}


####################################################################

sub grp2eps {
	my ($eps,$g)=@_;
	
	my @corepoly = text2poly($g->get_graph_attribute("polygon")) ;

	$eps->polygon(poly2list(polygon_move(dx=>((-1)*$corepoly[0][0]),dy=>((-1)*$corepoly[0][1]),@corepoly)));

	my @vers = $g->vertices;
	foreach my $ver (@vers) {
		my @verval = $g->get_vertex_attribute_values($ver);
		my @vername = $g->get_vertex_attribute_names($ver);
		my @polygon = text2poly($g->get_vertex_attribute($ver,"polygon")) ;
		my @polymov = polygon_move( dx=>((-1)*$corepoly[0][0]),dy=>((-1)*$corepoly[0][1]),@polygon);
		$eps->setcolour("blue");
		$eps->polygon(poly2list(@polymov));
		$eps->setcolour("red");
		$eps->setfont("Times-Roman", 30);
		$eps->text($polymov[0][0]+0.2,$polymov[0][1]+0.2, "$ver");
	}
}

####################################################################
sub vertices_bbox {
  my ($g,@vers)=@_;
  my @allPoly;
  foreach my $ver (@vers) {
    my @curPoly=text2poly($g->get_vertex_attribute($ver,"polygon"));
    push(@allPoly,@curPoly);    
  }
  my ($minx,$miny,$maxx,$maxy)=polygon_bbox(@allPoly);
  return ([$minx,$miny],[$maxx,$miny],[$maxx,$maxy],[$minx,$maxy],[$minx,$miny]);
}
####################################################################

## Example: GridEPS($eps,1,2,@poly);
sub GridEPS {
  my ($eps,$xpitch,$ypitch,@poly)=@_;
  my @polyGridY=poly2grid($xpitch,"Y",@poly);
  my @polyGridX=poly2grid($ypitch,"X",@poly);
  segments2eps($eps,@polyGridY);
  segments2eps($eps,@polyGridX);
}

sub SmoothTCG {
	my ($g,$thresh)=@_;
	my @edges = $g->edges;
	foreach my $edgel (@edges) {
		my @edge=@$edgel;
		my $maxsl = $g->get_edge_attribute($edge[0],$edge[1],"maxsl");
		if ($maxsl > $thresh) { $g->delete_edge($edge[0],$edge[1]) };
	}
}

###########Geometry extra################

sub poly2list { 
	my @poly=@_;
	my @list;
	foreach my $point (@poly) {
		push(@list,@{$point});
	}
	return @list;
}

sub list2poly {
	my @list=@_;
	my @poly;
	if (scalar(@list) % 2) {return undef}
	while (scalar(@list)) {
		push(@poly,[shift(@list),shift(@list)]);
	}
	return @poly;
}	

sub text2poly {
	my $text=$_[0];
	my @list=split(/\s+/,$text);
	return list2poly(@list);
}	


###########Graph extra################

#########################################
sub removeSelfLoop {
  my ($g)=@_;
  my @edges = $g->edges;
  foreach my $edge (@edges) {
    #my @edge=@$edgel;
    #my $maxsl = $g->get_edge_attribute($edge[0],$edge[1],"maxsl");
    if ($edge->[0] eq $edge->[1]) { $g->delete_edge($edge->[0],$edge->[1]) };
  }
}  


sub vertexUpdateLabel {
  my ($g,$ver)=@_;
  my @verPoly  = $g->get_vertex_attribute($ver,"polygon");
  my $cmaxr    = $g->get_vertex_attribute($ver,"cmaxr");
  my $cmaxf    = $g->get_vertex_attribute($ver,"cmaxf");
  my $cminr    = $g->get_vertex_attribute($ver,"cminr");
  my $cminf    = $g->get_vertex_attribute($ver,"cminf");  
  my ($minx,$miny,$maxx,$maxy)=polygon_bbox(text2poly(@verPoly));
  $g->set_vertex_attribute($ver,"label","$ver\n($minx,$miny\)($maxx,$maxy\)\ncmaxrf=[$cmaxr,$cmaxf]");
}

##  example: set_vertices_attribute(leaf,1,$g->vertices)
sub set_vertices_attribute {
  my ($name,$value,@vers)=@_;
  foreach my $ver (@vers) {
    $g->set_vertex_attribute($ver, $name, $value);
  }
}

sub mergeVertices {
  my ($g,$newVertex,@vers)=@_;
  $g->add_vertex($newVertex);
  
  my $cmaxr;
  my $cmaxf;
  my $cminr;
  my $cminf;

  foreach my $ver (@vers) {
    my @edgesFrom = $g->edges_from($ver);
    my @edgesTo   = $g->edges_to($ver);
    
    $cmaxr += $g->get_vertex_attribute($ver,"cmaxr");
    $cmaxf += $g->get_vertex_attribute($ver,"cmaxf");
    $cminr += $g->get_vertex_attribute($ver,"cminr");
    $cminf += $g->get_vertex_attribute($ver,"cminf");
    
    foreach my $edgeFrom (@edgesFrom) {
      if ($edgeFrom->[0] eq $edgeFrom->[1]) {next;} ## skip if loop
      moveEdge($g,$edgeFrom->[0],$edgeFrom->[1],$newVertex,$edgeFrom->[1]);
    }
    foreach my $edgeTo   (@edgesTo)   {
      if ($edgeTo->[0] eq $edgeTo->[1]) {next;} ## skip if loop
      moveEdge($g,$edgeTo->[0],$edgeTo->[1],$edgeTo->[0],$newVertex);
    }
    $g->delete_vertex($ver);  
  }
  
  $g->set_vertex_attribute($newVertex,"cmaxr",$cmaxr);
  $g->set_vertex_attribute($newVertex,"cmaxf",$cmaxf);
  $g->set_vertex_attribute($newVertex,"cminr",$cminr); 
  $g->set_vertex_attribute($newVertex,"cminf",$cminf);
  
}


sub moveEdge {
  my ($g,$su,$sv,$tu,$tv)=@_;
  if ( ($su eq $tu) && ($sv eq $tv) ) {return;} ## same edge 
  copyEdge($g,$su,$sv,$tu,$tv);
  $g->delete_edge($su,$sv);
}  
sub copyEdge {
  my ($g,$su,$sv,$tu,$tv)=@_;
  if ( ($su eq $tu) && ($sv eq $tv) ) {return;} ## same edge 
  if (!$g->has_edge($tu,$tv)) {$g->add_edge($tu,$tv);}
  copyEdgeAttribute($g,$su,$sv,$tu,$tv);
}
sub copyEdgeAttribute {
  my ($g,$su,$sv,$tu,$tv)=@_;
  if ( ($su eq $tu) && ($sv eq $tv) ) {return;} ## same edge 
  my $maxsl=$g->get_edge_attribute($su,$sv,"maxsl");
  my $minsl=$g->get_edge_attribute($su,$sv,"minsl");
  if ($g->has_edge_attribute($tu,$tv,"maxsl")) {
    my $tmaxsl=$g->get_edge_attribute($tu,$tv,"maxsl");
    if ($tmaxsl<$maxsl) {$maxsl=$tmaxsl}
  }
  if ($g->has_edge_attribute($tu,$tv,"minsl")) {
    my $tminsl=$g->get_edge_attribute($tu,$tv,"minsl");
    if ($tminsl>$minsl) {$minsl=$tminsl}
  }
  $g->set_edge_attribute($tu,$tv,"maxsl",$maxsl);
  $g->set_edge_attribute($tu,$tv,"minsl",$minsl);
  $g->set_edge_attribute($tu,$tv,"label","$maxsl\\n$minsl");
}  
