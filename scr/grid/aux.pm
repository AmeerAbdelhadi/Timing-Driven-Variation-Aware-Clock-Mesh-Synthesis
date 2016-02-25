#!/usr/bin/perl

####################################################
## Name    : aux.pm                               ##
## Synopsis: Contains auxiliary functions module  ##
## Author  : Ameer Abdelhadi                      ##
## Email   : aameer.abdelhadi@gmail.com           ##
####################################################

BEGIN{ push(@INC,"/hp/ameer/cgs/scr/pm"); }

package aux;	# aux module definition

use strict;	# Install all strictures
use FileHandle;	# Use file handle, for dealing with files
use GraphViz;	# Use graph visualization module
use warnings;	# Show warnings
$|++;		# Force auto flush of output buffer


#######################################################
## Synopsis:	Returns min.max values of an array   ##	
## Input:	Array of numbers                     ##
## Output:	Two elements array, contains min/max ##
## Complexity:	O(input array size)                  ##
#######################################################
sub minmax {
	my ($package,@arr)=@_;
	my $minval=$arr[0];
	my $maxval=$arr[0];
	## Iterate on array and update min/max
	foreach my $val (@arr) {
		if ($val<$minval) {
			$minval=$val;
		}
		if ($val>$maxval) {
			$maxval=$val;
		}
	}
	## return min/max values
	return ($minval,$maxval);
}

############################################################
## Synopsis:	Sort & unify array (no repeated elements) ##	
## Input:	Array of numbers                          ##
## Output:	Sorted and unified array                  ##
## Complexity:	O(input array size)                       ##
############################################################
sub sort_uniq {
	my ($package,@arr)=@_;
	my @sorted_arr=sort {$a <=> $b} @arr; ## numerical sort
	my @sorted_uniq_arr;
	my $prev_val=undef;
	## iterate on sorted array to remove repeated numbers 
	foreach my $val (@sorted_arr) {
		unless ((defined $prev_val) && ($val == $prev_val)) {push(@sorted_uniq_arr,$val);}
		$prev_val=$val;
	}
	return @sorted_uniq_arr;
}
