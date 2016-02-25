#!/usr/bin/perl


##########################################################################################
## Name    : net2grp.pl                                                                 ##
## Author  : Ameer Abdel-hadi                                                           ##
## Email   : ameer.abdelhadi@gmail.com                                                  ##
##                                                                                      ##
## SYNOPSIS:                                                                            ##
##   Converts Verilog netlist into graph                                                ##
##   Generate registers connectivity graph                                              ##
## USAGE:                                                                               ##
##   net2grp.pl -net <verilog netlist> [-rc [<tcl>] -di [<png>] -do [<png>]]            ##
## PARAMETERS:                                                                          ##
##   -netlist|net <net file>: input Verilog netlist file                                ##
##   -regscon|rc  <tcl file>: make all cells but registers transparent                  ##
##                            save only registers connectivity                          ##
##                            report to <tcl file>, if isn't specified report to STDOUT ##
##   -drawin |di  <png file>: draw input netlist graph into <png file>                  ##
##                            if <png file> isn't specified draw to <net file>.in.png   ##
##   -drawout|do  <png file>: draw output netlist graph into <png file>                 ##
##                            if <png file> isn't specified draw to <net file>.out.png  ##
##   -help|h: print this message                                                        ##
##   > (-netlist) and at least one of (-regscon) or (-drawin) or (-drawout)are required ##
## EXAMPLE:                                                                             ##
##   congrp.pl -net s27.bgx.vh -rc                                                      ##
## REPORT BUGS:                                                                         ##
##   Ameer Abdel-hadi (ameer.abdelhadi\@gmail.com)                                      ##
##                                                                                      ##
##########################################################################################

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

my %options=();
if ( ! &GetOptions (
        "netlist|net:s"	=>\$options{netlist},
        "regscon|rc:s"	=>\$options{regscon},
        "drawin|di:s"	=>\$options{drawin},
        "drawout|do:s"	=>\$options{drawout},
        "h|help"	=>\$options{help}
) || $options{help} || (!$options{netlist}) || ( !defined($options{regscon}) && !defined($options{drawin}) && !defined($options{drawout}) ) ) {
print STDOUT <<END_OF_HELP;
SYNOPSIS:
  Converts Verilog netlist into graph
  Generate registers connectivity graph
USAGE:
  congrp.pl -net <verilog netlist> [-rc [<tcl>] -di [<png>] -do [<png>]]
PARAMETERS:
  -netlist|net <net file>: input Verilog netlist file
  -regscon|rc  <tcl file>: make all cells but registers transparent
                           save only registers connectivity
                           report to <tcl file>, if isn't specified report to STDOUT
  -drawin |di  <png file>: draw input netlist graph into <png file> 
                           if <png file> isn't specified draw to <net file>.in.png
  -drawout|do  <png file>: draw output netlist graph into <png file> 
                           if <png file> isn't specified draw to <net file>.out.png
  -help|h: print this message 
  > (-netlist) and at least one of (-regscon) or (-drawin) or (-drawout) are required
EXAMPLE:
  congrp.pl -net s27.bgx.vh -rc
REPORT BUGS:
  Ameer Abdelhadi (ameer.abdelhadi\@gmail.com)
END_OF_HELP
exit;
}


###############################################
my $netlistFileName=$options{netlist};

my $netlistGraph = netlist2Graph($netlistFileName);
removeSelfLoop($netlistGraph);


my $wr_png = Graph::Writer::GraphViz->new(-format => 'png');
if (defined($options{drawin})) {
  my $pngInFN = $options{drawin} ? "$options{drawin}" : "$netlistFileName.in.png";
  $wr_png->write_graph($netlistGraph,$pngInFN);
}

transparentAllButRegs($netlistGraph);
removeSelfLoop($netlistGraph);

if (defined($options{drawout})) {
  my $pngOutFN = $options{drawout} ? "$options{drawout}" : "$netlistFileName.out.png";
  $wr_png->write_graph($netlistGraph,$pngOutFN);
}

if (defined($options{regscon})) {
  reportConnectivity($netlistGraph,$options{regscon});
}  


################################################
##                                            ##
##  report connectivity to tcl file or STDOUT ##
##  in tcl format                             ##
################################################

sub reportConnectivity {
  my ($netlistGraph,$reportFileName)=@_;
  
  *TCLHND=*STDOUT;
  if ($reportFileName) {
    open (TCLHND,">$reportFileName") || die "Cannot open $reportFileName. Program terminated!\n";
  }
  
  my @cells=$netlistGraph->vertices;
  foreach my $cell (@cells) {
    my $temp = $netlistGraph->get_vertex_attribute($cell,"template");
    if ( ($temp eq "DFFSR") || ($temp eq "DFFPOSX1") ) { 
      my @edgesFrom = $netlistGraph->edges_from($cell);
      my @nodesFrom = map {$_->[1]} @edgesFrom;
      print TCLHND "set connectivity($cell) {@nodesFrom}\n";
    }
  }
  
}

################################################
##                                            ##
##  converts verilog netlist file into graph  ##
##                                            ##
################################################

sub netlist2Graph {

  my ($netlistFileName)=@_;  
  my %nets = ();
  my $netlistGraph = Graph->new;  
  
  open (NETHND,"<$netlistFileName") || die "Cannot open ${netlistFileName}. Program terminated!\n";
  my @netlistLines=<NETHND>;
  chomp(@netlistLines);
  
  while (@netlistLines) {
    my $netlistLine=shift(@netlistLines);
    
    ## remove comments and empty line
    if (($netlistLine =~ /^\s*\/\//) || ($netlistLine =~ /^\s*$/))  {next;}
    
    ## ignore endmodule
    if ($netlistLine =~ /^\s*endmodule\s*$/)  {next;}
    
    ## if command spread on multi-lines, gather it
    while ($netlistLine !~ /\;\s*$/) {$netlistLine.=shift(@netlistLines)}
    
    ## unvictorize inputs/outputs
    if ($netlistLine =~ /^(.*)\[(\d*)\:(\d*)\](.*)\s*\;\s*$/) {
      my $toIndex=$2;
      my $fromIndex=$3;
      for (my $i=$fromIndex;$i<=$toIndex;$i++) {
        unshift(@netlistLines,"$1 $4__${i}__;");
      }
      next;
    }

    ## syntax subsitution
    $netlistLine =~ s/\[/__/g;
    $netlistLine =~ s/\]/__/g;
    $netlistLine =~ s/\\//g;   
    $netlistLine =~ s/^\s*//g;
    $netlistLine =~ s/\s+/ /g;
    
     #### print ">> $netlistLine\n";
        
    ## module
    if (($netlistLine =~ /^\s*module\s*(\S*)\s*\((.*)\)\;/))  {
      my $moduleName = $1;
      my @ports = split(/\s*\,\s*/,$2);
    }
    
    ## inputs
    if (($netlistLine =~ /^\s*input\s*(\S*)\s*\;/))  {
      my  $input = $1;
      $netlistGraph->add_vertex("$input");
      $netlistGraph->set_vertex_attribute($input,"template","input");
      $netlistGraph->set_vertex_attribute($input,"label","input\n$input");
      $netlistGraph->set_vertex_attribute($input,"shape","diamond");
      $netlistGraph->set_vertex_attribute($input,"color","blue");
      push(@{$nets{$input}},$input);
    }
    ## outputs
    if (($netlistLine =~ /^\s*output\s*(\S*)\s*\;/))  {
      my  $output = $1;
      $netlistGraph->add_vertex("$output");
      $netlistGraph->set_vertex_attribute($output,"template","output");
      $netlistGraph->set_vertex_attribute($output,"label","output\n$output");
      $netlistGraph->set_vertex_attribute($output,"shape","diamond");
      $netlistGraph->set_vertex_attribute($output,"color","blue");
      unshift(@{$nets{$output}},$output);
    }
       
    ## instantiation
    if ($netlistLine =~ /\s*(\S*)\s*(\S*)\(\s*(\..*)\)\s*\;/) {
      my $temp = $1;
      my $inst = $2;
      my $pinsList=$3;

      if ($temp eq "generic_dpram_gen_0") {next;} # temporary skip this
      
      ## get pins list
      $pinsList =~ s/\s*//g;		# remove spaces from pins list
      $pinsList =~ s/\{//g;		# remove {
      $pinsList =~ s/\}//g;		# remove }
      $pinsList =~ s/\.[^\(]*\(/\(/g;	# remove .pin
      $pinsList =~ s/\(//g;		# remove (
      $pinsList =~ s/\)//g;		# remove )
      $pinsList =~ s/\,\d\'\D\d//g;     # remove constants e.g. ,1'b1
      my @pins=split(/\,/,$pinsList);       
      $netlistGraph->add_vertex("$inst");
      $netlistGraph->set_vertex_attribute($inst,"template","$temp");
      $netlistGraph->set_vertex_attribute($inst,"label","$inst\n$temp");

      if ($temp eq "DFFSR") {
        @pins=@pins[0,1,3,2];        
        $netlistGraph->set_vertex_attribute($inst,"shape","box");
        $netlistGraph->set_vertex_attribute($inst,"color","red");	
      }
      if ($temp eq "DFFPOSX1") {
        $netlistGraph->set_vertex_attribute($inst,"shape","box");
        $netlistGraph->set_vertex_attribute($inst,"color","red");	
      }

      #### print "-- @pins\n";
      
      unshift(@{$nets{pop(@pins)}},$inst);
      foreach my $pin (@pins) {
        push(@{$nets{$pin}},$inst);
      }      
    }
    
  }
  
  while ( my ($net, $instance) = each(%nets) ) {
    my @nets=@{$instance};
    my $source=shift(@nets);
    foreach my $target (@nets) {
      $netlistGraph->add_edge("$source", "$target" );
      $netlistGraph->set_edge_attribute($source,$target,"label", $net);
    }
  }
  
  return $netlistGraph;
}

#################################################
##  makes a cell taransparent a netlist graph  ##
##  removes node and move edges to neighbors   ##
##                                             ##
#################################################

sub transparentCell {
  my ($g,$cell)=@_;
  my @edgesFrom = $g->edges_from($cell);
  my @edgesTo   = $g->edges_to($cell);
  foreach my $edgeTo (@edgesTo) {
    foreach my $edgeFrom (@edgesFrom) {
      copyEdge($g,$edgeTo->[0],$edgeTo->[1],$edgeTo->[0],$edgeFrom->[1]);
    }
  }
  $g->delete_vertex($cell);
}

#################################################
##  copy graph's edge from source to target    ##
##                                             ##
##                                             ##
#################################################

sub copyEdge {
  my ($g,$su,$sv,$tu,$tv)=@_;
  if ($g->has_edge($su,$sv)) {
    if ( ($su eq $tu) && ($sv eq $tv) ) {return;} ## same edge 
    if (!$g->has_edge($tu,$tv)) {$g->add_edge($tu,$tv);}
    my $attrHash = $g->get_edge_attributes($su,$sv);
    while ( my ($attrName, $attrValue) = each(%$attrHash) ) {
      $g->set_edge_attribute($tu,$tv,$attrName,$attrValue);
    }
  }
}

#################################################
##  make all cells but regeiters transparent   ##
##  remove all cells but registers and save    ##
##  connectivity                               ##
#################################################

sub transparentAllButRegs {
  my ($g)=@_;
  my @cells=$g->vertices;
  foreach my $cell (@cells) {
    my $temp = $g->get_vertex_attribute($cell,"template");
    if ( ($temp ne "DFFSR") && ($temp ne "DFFPOSX1") ) { 
      transparentCell($g,$cell);
    }
  }
}

#################################################
##                                             ##
##  remove self loops from a graph             ##
##                                             ##
#################################################
 
sub removeSelfLoop {
  my ($g)=@_;
  my @edges = $g->edges;
  foreach my $edge (@edges) {
    if ($edge->[0] eq $edge->[1]) { $g->delete_edge($edge->[0],$edge->[1]) };
  }
}  
