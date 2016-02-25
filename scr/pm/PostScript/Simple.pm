#! /usr/bin/perl -w

package PostScript::Simple;

use strict;
use vars qw($VERSION @ISA @EXPORT);
use Carp;
use Exporter;
use PostScript::Simple::EPS;

@ISA = qw(Exporter);
@EXPORT = qw();
$VERSION = '0.07';

=head1 NAME

PostScript::Simple - Produce PostScript files from Perl

=head1 SYNOPSIS

    use PostScript::Simple;
    
    # create a new PostScript object
    $p = new PostScript::Simple(papersize => "A4",
                                colour => 1,
                                eps => 0,
                                units => "in");
    
    # create a new page
    $p->newpage;
    
    # draw some lines and other shapes
    $p->line(1,1, 1,4);
    $p->linextend(2,4);
    $p->box(1.5,1, 2,3.5);
    $p->circle(2,2, 1);
    $p->setlinewidth( 0.01 );
    $p->curve(1,5, 1,7, 3,7, 3,5);
    $p->curvextend(3,3, 5,3, 5,5);
    
    # draw a rotated polygon in a different colour
    $p->setcolour(0,100,200);
    $p->polygon({rotate=>45}, 1,1, 1,2, 2,2, 2,1, 1,1);
    
    # add some text in red
    $p->setcolour("red");
    $p->setfont("Times-Roman", 20);
    $p->text(1,1, "Hello");
    
    # write the output to a file
    $p->output("file.ps");


=head1 DESCRIPTION

PostScript::Simple allows you to have a simple method of writing PostScript
files from Perl. It has graphics primitives that allow lines, curves, circles,
polygons and boxes to be drawn. Text can be added to the page using standard
PostScript fonts.

The images can be single page EPS files, or multipage PostScript files. The
image size can be set by using a recognised paper size ("C<A4>", for example) or
by giving dimensions. The units used can be specified ("C<mm>" or "C<in>", etc)
and are the same as those used in TeX. The default unit is a bp, or a PostScript
point, unlike TeX.

=head1 PREREQUISITES

This module requires C<strict> and C<Exporter>.

=head2 EXPORT

None.

=cut


# is there another colour database that can be used instead of defining
# this one here? what about the X-windows one? (apart from MS-Win-probs?) XXXXX
my %pscolours = (# {{{
  black         => "0    0    0",
  brightred     => "1    0    0",
  brightgreen   => "0    1    0",
  brightblue    => "0    0    1",
  red           => "0.8  0    0",
  green         => "0    0.8  0",
  blue          => "0    0    0.8",
  darkred       => "0.5  0    0",
  darkgreen     => "0    0.5  0",
  darkblue      => "0    0    0.5",
  grey10        => "0.1  0.1  0.1",
  grey20        => "0.2  0.2  0.2",
  grey30        => "0.3  0.3  0.3",
  grey40        => "0.4  0.4  0.4",
  grey50        => "0.5  0.5  0.5",
  grey60        => "0.6  0.6  0.6",
  grey70        => "0.7  0.7  0.7",
  grey80        => "0.8  0.8  0.8",
  grey90        => "0.9  0.9  0.9",
  white         => "1    1    1",
);# }}}


# define page sizes here (a4, letter, etc)
# should be Properly Cased
my %pspaper = (# {{{
  A0                    => '2384 3370',
  A1                    => '1684 2384',
  A2                    => '1191 1684',
  A3                    => "841.88976 1190.5512",
  A4                    => "595.27559 841.88976",
  A5                    => "420.94488 595.27559",
  A6                    => '297 420',
  A7                    => '210 297',
  A8                    => '148 210',
  A9                    => '105 148',

  B0                    => '2920 4127',
  B1                    => '2064 2920',
  B2                    => '1460 2064',
  B3                    => '1032 1460',
  B4                    => '729 1032',
  B5                    => '516 729',
  B6                    => '363 516',
  B7                    => '258 363',
  B8                    => '181 258',
  B9                    => '127 181 ',
  B10                   => '91 127',

  Executive             => '522 756',
  Folio                 => '595 935',
  'Half-Letter'         => '612 397',
  Letter                => "612 792",
  'US-Letter'           => '612 792',
  Legal                 => '612 1008',
  'US-Legal'            => '612 1008',
  Tabloid               => '792 1224',
  'SuperB'              => '843 1227',
  Ledger                => '1224 792',

  'Comm #10 Envelope'   => '297 684',
  'Envelope-Monarch'    => '280 542',
  'Envelope-DL'         => '312 624',
  'Envelope-C5'         => '461 648',

  'EuroPostcard'        => '298 420',
);# }}}


# The 13 standard fonts that are available on all PS 1 implementations:
my @fonts = (# {{{
    'Courier',
    'Courier-Bold',
    'Courier-BoldOblique',
    'Courier-Oblique',
    'Helvetica',
    'Helvetica-Bold',
    'Helvetica-BoldOblique',
    'Helvetica-Oblique',
    'Times-Roman',
    'Times-Bold',
    'Times-BoldItalic',
    'Times-Italic',
    'Symbol');# }}}

# define the origins for the page a document can have
# (default is "LeftBottom")
my %psorigin = (# {{{
  'LeftBottom'  => '0 0',
  'LeftTop'     => '0 -1',
  'RightBottom' => '-1 0',
  'RightTop'    => '-1 -1',
);# }}}

# define the co-ordinate direction (default is 'RightUp')
my %psdirs = (# {{{
  'RightUp'  => '1 1',
  'RightDown'   => '1 -1',
  'LeftUp'  => '-1 1',
  'LeftDown'   => '-1 -1',
);# }}}


# measuring units are two-letter acronyms as used in TeX:
#  bp: postscript point (72 per inch)
#  in: inch (72 postscript points)
#  pt: printer's point (72.27 per inch)
#  mm: millimetre (25.4 per inch)
#  cm: centimetre (2.54 per inch)
#  pi: pica (12 printer's points)
#  dd: didot point (67.567. per inch)
#  cc: cicero (12 didot points)

#  set up the others here (sp) XXXXX

my %psunits = (# {{{
  pt   => "72 72.27",
  pc   => "72 6.0225",
  in   => "72 1",
  bp   => "1 1",
  cm   => "72 2.54",
  mm   => "72 25.4",
  dd   => "72 67.567",
  cc   => "72 810.804",
);# }}}


=head1 CONSTRUCTOR

=over 4

=item C<new(options)>

Create a new PostScript::Simple object. The different options that can be set are:

=over 4

=item units

Units that are to be used in the file. Common units would be C<mm>, C<in>,
C<pt>, C<bp>, and C<cm>. Others are as used in TeX. (Default: C<bp>)

=item xsize

Specifies the width of the drawing area in units.

=item ysize

Specifies the height of the drawing area in units.

=item papersize

The size of paper to use, if C<xsize> or C<ysize> are not defined. This allows
a document to easily be created using a standard paper size without having to
remember the size of paper using PostScript points. Valid choices are currently
"C<A3>", "C<A4>", "C<A5>", and "C<Letter>".

=item landscape

Use the landscape option to rotate the page by 90 degrees. The paper dimensions
are also rotated, so that clipping will still work. (Note that the printer will
still think that the paper is portrait.) (Default: 0)

=item copies

Set the number of copies that should be printed. (Default: 1)

=item clip

If set to 1, the image will be clipped to the xsize and ysize. This is most
useful for an EPS image. (Default: 0)

=item colour

Specifies whether the image should be rendered in colour or not. If set to 0
(default) all requests for a colour are mapped to a greyscale. Otherwise the
colour requested with C<setcolour> or C<line> is used. This option is present
because most modern laser printers are only black and white. (Default: 0)

=item eps

Generate an EPS file, rather than a standard PostScript file. If set to 1, no
newpage methods will actually create a new page. This option is probably the
most useful for generating images to be imported into other applications, such
as TeX. (Default: 1)

=item page

Specifies the initial page number of the (multi page) document. The page number
is set with the Adobe DSC comments, and is used nowhere else. It only makes
finding your pages easier. See also the C<newpage> method. (Default: 1)

=item coordorigin

Defines the co-ordinate origin for each page produced. Valid arguments are
C<LeftBottom>, C<LeftTop>, C<RightBottom> and C<RightTop>. The default is
C<LeftBottom>.

=item direction

The direction the co-ordinates go from the origin. Values can be C<RightUp>,
C<RightDown>, C<LeftUp> and C<LeftDown>. The default value is C<RightUp>.

=item reencode

Requests that a font re-encode function be added and that the 13 standard
PostScript fonts get re-encoded in the specified encoding. The most popular
choice (other than undef) is 'ISOLatin1Encoding' which selects the iso8859-1
encoding and fits most of western Europe, including the Scandinavia. Refer to
Adobes Postscript documentation for other encodings.

The output file is, by default, re-encoded to ISOLatin1Encoding. To stop this
happening, use 'reencode => undef'. To use the re-encoded font, '-iso' must be
appended to the names of the fonts used, e.g. 'Helvetica-iso'.

=back

Example:

    $ref = new PostScript::Simple(landscape => 1,
                                  eps => 0,
                                  xsize => 4,
                                  ysize => 3,
                                  units => "in");

Create a document that is 4 by 3 inches and prints landscape on a page. It is
not an EPS file, and must therefore use the C<newpage> method.

    $ref = new PostScript::Simple(eps => 1,
                                  colour => 1,
                                  xsize => 12,
                                  ysize => 12,
                                  units => "cm",
                                  reencode => "ISOLatin1Encoding");

Create a 12 by 12 cm EPS image that is in colour. Note that "C<eps =E<gt> 1>"
did not have to be specified because this is the default. Re-encode the
standard fonts into the iso8859-1 encoding, providing all the special characters
used in Western Europe. The C<newpage> method should not be used.

=back

=cut


sub new# {{{
{
  my ($class, %data) = @_;
  my $self = {
    xsize          => undef,
    ysize          => undef,
    papersize      => undef,
    units          => "bp",     # measuring units (see below)
    landscape      => 0,        # rotate the page 90 degrees
    copies         => 1,        # number of copies
    colour         => 0,        # use colour
    clip           => 0,        # clip to the bounding box
    eps            => 1,        # create eps file
    page           => 1,        # page number to start at
    reencode       => "ISOLatin1Encoding", # Re-encode the 13 standard
                                           # fonts in this encoding

    bbx1           => 0,        # Bounding Box definitions
    bby1           => 0,
    bbx2           => 0,
    bby2           => 0,

    pscomments     => "",       # the following entries store data
    psprolog       => "",       # for the same DSC areas of the
    psfunctions    => "",       # postscript file.
    pssetup        => "",
    pspages        => "",
    pstrailer      => "",

    lastfontsize   => 0,
    pspagecount    => 0,
    usedcircle     => 0,
    usedcircletext => 0,
    usedbox        => 0,
    usedrotabout   => 0,
    usedimporteps  => 0,

    coordorigin    => 'LeftBottom',
    direction      => 'RightUp',
  };

  foreach (keys %data)
  {
    $self->{$_} = $data{$_};
  }

  bless $self, $class;
  $self->init();

  return $self;
}# }}}

sub init# {{{
{
  my $self = shift;

  my ($m, $d) = (1, 1);
  my ($u, $mm);
  my ($dx, $dy);

# Units# {{{
  if (defined $self->{units})
  {
    $self->{units} = lc $self->{units};
  }

  if (defined($psunits{$self->{units}}))
  {
    ($m, $d) = split(/\s+/, $psunits{$self->{units}});
  }
  else
  {
    $self->_error( "unit '$self->{units}' undefined" );
  }

  ($dx, $dy) = split(/\s+/, $psdirs{$self->{direction}});

# X direction
  $mm = $m * $dx;
  $u = "{";
  if ($mm != 1) { $u .= "$mm mul " }
  if ($d != 1) { $u .= "$d div " }
  $u =~ s/ $//;
  $u .="}";
  $self->{psfunctions} .= "/ux $u def\n";

# Y direction
  $mm = $m * $dy;
  $u = "{";
  if ($mm != 1) { $u .= "$mm mul " }
  if ($d != 1) { $u .= "$d div " }
  $u =~ s/ $//;
  $u .="}";
  $self->{psfunctions} .= "/uy $u def\n";

# General unit scale (circle radius, etc)
  $u = "{";
  if ($m != 1) { $u .= "$m mul " }
  if ($d != 1) { $u .= "$d div " }
  $u =~ s/ $//;
  $u .="}";
  $self->{psfunctions} .= "/u $u def\n";

  #$u = "{";
  #if ($m != 1) { $u .= "$m mul " }
  #if ($d != 1) { $u .= "$d div " }
  #$u =~ s/ $//;
  #$u .="}";
  #
  #$self->{psfunctions} .= "/u $u def\n";# }}}

# Paper size# {{{
  if (defined $self->{papersize})
  {
    $self->{papersize} = ucfirst lc $self->{papersize};
  }

  if (!defined $self->{xsize} || !defined $self->{ysize})
  {
    if (defined $self->{papersize} && defined $pspaper{$self->{papersize}})
    {
      ($self->{xsize}, $self->{ysize}) = split(/\s+/, $pspaper{$self->{papersize}});
      $self->{bbx2} = int($self->{xsize});
      $self->{bby2} = int($self->{ysize});
      $self->{pscomments} .= "\%\%DocumentMedia: $self->{papersize} $self->{xsize} ";
      $self->{pscomments} .= "$self->{ysize} 0 ( ) ( )\n";
     }
    else
    {
      ($self->{xsize}, $self->{ysize}) = (100,100);
      $self->_error( "page size undefined" );
    }
  }
  else
  {
    $self->{bbx2} = int(($self->{xsize} * $m) / $d);
    $self->{bby2} = int(($self->{ysize} * $m) / $d);
  }# }}}

  if (!$self->{eps}) {
    $self->{pssetup} .= "ll 2 ge { << /PageSize [ $self->{xsize} " .
                        "$self->{ysize} ] /ImagingBBox null >>" .
                        " setpagedevice } if\n";
  }

# Landscape# {{{
  if ($self->{landscape})
  {
    my $swap;

    $self->{psfunctions} .= "/landscape {
  $self->{bbx2} 0 translate
  90 rotate
} bind def
";
    # I now think that Portrait is the correct thing here, as the page is
    # rotated.
    $self->{pscomments} .= "\%\%Orientation: Portrait\n";
#    $self->{pscomments} .= "\%\%Orientation: Landscape\n";
    $swap = $self->{bbx2};
    $self->{bbx2} = $self->{bby2};
    $self->{bby2} = $swap;

    # for EPS files, change to landscape here, as there are no pages
    if ($self->{eps}) { $self->{pssetup} .= "landscape\n" }
  }
  else
  {
    $self->{pscomments} .= "\%\%Orientation: Portrait\n";
  }# }}}
  
# Clipping# {{{
  if ($self->{clip})
  {
    $self->{psfunctions} .= "/pageclip {newpath $self->{bbx1} $self->{bby1} moveto
$self->{bbx1} $self->{bby2} lineto
$self->{bbx2} $self->{bby2} lineto
$self->{bbx2} $self->{bby1} lineto
$self->{bbx1} $self->{bby1} lineto
closepath clip} bind def
";
    if ($self->{eps}) { $self->{pssetup} .= "pageclip\n" }
  }# }}}

# Font reencoding# {{{
  if ($self->{reencode})
  {
    my $encoding; # The name of the encoding
    my $ext;      # The extention to tack onto the std fontnames

    if (ref $self->{reencode} eq 'ARRAY')
    {
      die "Custom reencoding of fonts not really implemented yet, sorry...";
      $encoding = shift @{$self->{reencode}};
      $ext = shift @{$self->{reencode}};
      # TODO: Do something to add the actual encoding to the postscript code.
    }
    else
    {
      $encoding = $self->{reencode};
      $ext = '-iso';
    }

    $self->{psfunctions} .= <<'EOP';
/STARTDIFFENC { mark } bind def
/ENDDIFFENC { 

% /NewEnc BaseEnc STARTDIFFENC number or glyphname ... ENDDIFFENC -
	counttomark 2 add -1 roll 256 array copy
	/TempEncode exch def
	
	% pointer for sequential encodings
	/EncodePointer 0 def
	{
		% Get the bottom object
		counttomark -1 roll
		% Is it a mark?
		dup type dup /marktype eq {
			% End of encoding
			pop pop exit
		} {
			/nametype eq {
			% Insert the name at EncodePointer 

			% and increment the pointer.
			TempEncode EncodePointer 3 -1 roll put
			/EncodePointer EncodePointer 1 add def
			} {
			% Set the EncodePointer to the number
			/EncodePointer exch def
			} ifelse
		} ifelse
	} loop	

	TempEncode def
} bind def

% Define ISO Latin1 encoding if it doesnt exist
/ISOLatin1Encoding where {
%	(ISOLatin1 exists!) =
	pop
} {
	(ISOLatin1 does not exist, creating...) =
	/ISOLatin1Encoding StandardEncoding STARTDIFFENC
		144 /dotlessi /grave /acute /circumflex /tilde 
		/macron /breve /dotaccent /dieresis /.notdef /ring 
		/cedilla /.notdef /hungarumlaut /ogonek /caron /space 
		/exclamdown /cent /sterling /currency /yen /brokenbar 
		/section /dieresis /copyright /ordfeminine 
		/guillemotleft /logicalnot /hyphen /registered 
		/macron /degree /plusminus /twosuperior 
		/threesuperior /acute /mu /paragraph /periodcentered 
		/cedilla /onesuperior /ordmasculine /guillemotright 
		/onequarter /onehalf /threequarters /questiondown 
		/Agrave /Aacute /Acircumflex /Atilde /Adieresis 
		/Aring /AE /Ccedilla /Egrave /Eacute /Ecircumflex 
		/Edieresis /Igrave /Iacute /Icircumflex /Idieresis 
		/Eth /Ntilde /Ograve /Oacute /Ocircumflex /Otilde 
		/Odieresis /multiply /Oslash /Ugrave /Uacute 
		/Ucircumflex /Udieresis /Yacute /Thorn /germandbls 
		/agrave /aacute /acircumflex /atilde /adieresis 
		/aring /ae /ccedilla /egrave /eacute /ecircumflex 
		/edieresis /igrave /iacute /icircumflex /idieresis 
		/eth /ntilde /ograve /oacute /ocircumflex /otilde 
		/odieresis /divide /oslash /ugrave /uacute 
		/ucircumflex /udieresis /yacute /thorn /ydieresis
	ENDDIFFENC
} ifelse

% Name: Re-encode Font
% Description: Creates a new font using the named encoding. 

/REENCODEFONT { % /Newfont NewEncoding /Oldfont
	findfont dup length 4 add dict
	begin
		{ % forall
			1 index /FID ne 
			2 index /UniqueID ne and
			2 index /XUID ne and
			{ def } { pop pop } ifelse
		} forall
		/Encoding exch def
		% defs for DPS
		/BitmapWidths false def
		/ExactSize 0 def
		/InBetweenSize 0 def
		/TransformedChar 0 def
		currentdict
	end
	definefont pop
} bind def

% Reencode the std fonts: 
EOP
    
    for my $font (@fonts)
    {
      $self->{psfunctions} .= "/${font}$ext $encoding /$font REENCODEFONT\n";
    }
  }# }}}
}# }}}


=head1 OBJECT METHODS

All object methods return 1 for success or 0 in some error condition (e.g. insufficient arguments).
Error message text is also drawn on the page.

=over 4

=item C<newpage([number])>

Generates a new page on a PostScript file. If specified, C<number> gives the
number (or name) of the page. This method should not be used for EPS files.

The page number is automatically incremented each time this is called without
a new page number, or decremented if the current page number is negative.

Example:

    $p->newpage(1);
    $p->newpage;
    $p->newpage("hello");
    $p->newpage(-6);
    $p->newpage;

will generate five pages, numbered: 1, 2, "hello", -6, -7.

=cut


sub newpage# {{{
{
  my $self = shift;
  my $nextpage = shift;
  my ($x, $y);
  
  if (defined($nextpage)) { $self->{page} = $nextpage; }

  if ($self->{eps})
  {
# Cannot have multiple pages in an EPS file XXXXX
    $self->_error("Do not use newpage for eps files!");
    return 0;
  }

  if ($self->{pspagecount} != 0)
  {
    $self->{pspages} .= "\%\%PageTrailer\npagelevel restore\nshowpage\n";
  }

  $self->{pspagecount} ++;
  $self->{pspages} .= "\%\%Page: $self->{page} $self->{pspagecount}\n";
  if ($self->{page} >= 0)
  {    
    $self->{page} ++;
  }
  else
  {
    $self->{page} --;
  }

  $self->{pspages} .= "\%\%BeginPageSetup\n";
  $self->{pspages} .= "/pagelevel save def\n";
  if ($self->{landscape}) { $self->{pspages} .= "landscape\n" }
  if ($self->{clip}) { $self->{pspages} .= "pageclip\n" }
  ($x, $y) = split(/\s+/, $psorigin{$self->{coordorigin}});
  $x = $self->{xsize} if ($x < 0);
  $y = $self->{ysize} if ($y < 0);
  $self->{pspages} .= "$x $y translate\n" if (($x != 0) || ($y != 0));
  $self->{pspages} .= "\%\%EndPageSetup\n";

  return 1;
}# }}}


=item C<output(filename)>

Writes the current PostScript out to the file named C<filename>. Will destroy
any existing file of the same name.

Use this method whenever output is required to disk. The current PostScript
document in memory is not cleared, and can still be extended.

=cut


sub _builddocument# {{{
{
  my $self = shift;
  my $title = shift;
  
  my $page;
  my $date = scalar localtime;
  my $user;

  $title = 'undefined' unless $title;

  $page = [];

# getlogin is unimplemented on some systems
  eval { $user = getlogin; };
  $user = 'Console' unless $user;

# Comments Section
  push @$page, "%!PS-Adobe-3.0";
  push @$page, " EPSF-1.2" if ($self->{eps});
  push @$page, "\n";
  push @$page, "\%\%Title: ($title)\n";
  push @$page, "\%\%LanguageLevel: 1\n";
  push @$page, "\%\%Creator: PostScript::Simple perl module version $VERSION\n";
  push @$page, "\%\%CreationDate: $date\n";
  push @$page, "\%\%For: $user\n";
  push @$page, \$self->{pscomments};
#  push @$page, "\%\%DocumentFonts: \n";
  if ($self->{eps})
  {
    push @$page, "\%\%BoundingBox: $self->{bbx1} $self->{bby1} $self->{bbx2} $self->{bby2}\n";
  }
  else
  {
    push @$page, "\%\%Pages: $self->{pspagecount}\n";
  }
  push @$page, "\%\%EndComments\n";
  
# Prolog Section
  push @$page, "\%\%BeginProlog\n";
  push @$page, "/ll 1 def systemdict /languagelevel known {\n";
  push @$page, "/ll languagelevel def } if\n";
  push @$page, \$self->{psprolog};
  push @$page, "\%\%BeginResource: PostScript::Simple\n";
  push @$page, \$self->{psfunctions};
  push @$page, "\%\%EndResource\n";
  push @$page, "\%\%EndProlog\n";

# Setup Section
  if (length($self->{pssetup}) || ($self->{copies} > 1))
  {
    push @$page, "\%\%BeginSetup\n";
    if ($self->{copies} > 1)
    {
      push @$page, "/#copies " . $self->{copies} . " def\n";
    }
    push @$page, \$self->{pssetup};
    push @$page, "\%\%EndSetup\n";
  }

# Pages
  push @$page, \$self->{pspages};
  if ((!$self->{eps}) && ($self->{pspagecount} > 0))
  {
    push @$page, "\%\%PageTrailer\n";
    push @$page, "pagelevel restore\n";
    push @$page, "showpage\n";
  }

# Trailer Section
  if (length($self->{pstrailer}))
  {
    push @$page, "\%\%Trailer\n";
    push @$page, \$self->{pstrailer};
  }
  push @$page, "\%\%EOF\n";
  
  return $page;
}# }}}

sub output# {{{
{
  my $self = shift;
  my $file = shift || die("Must supply a filename for output");
  my $page;
  my $i;
  
  $page = _builddocument($self, $file);

  local *OUT;
  open(OUT, '>'.$file) or die("Cannot write to file $file: $!");

  foreach $i (@$page) {
    if (ref($i) eq "SCALAR") {
      print OUT $$i;
    } else {
      print OUT $i;
    }
  }

  close OUT;
  
  return 1;
}# }}}


=item C<get>

Returns the current document.

Use this method whenever output is required as a scalar. The current PostScript
document in memory is not cleared, and can still be extended.

=cut

sub get# {{{
{
  my $self = shift;
  my $page;
  my $i;
  my $doc;
  
  $page = _builddocument($self, "PostScript::Simple generated page");
  $doc = "";
  foreach $i (@$page) {
    if (ref($i) eq "SCALAR") {
      $doc .= $$i;
    } else {
      $doc .= $i;
    }
  }
  return $doc;
}# }}}


=item C<geteps>

Returns the current document as a PostScript::Simple::EPS object. Only works if
the current document is EPS.

This method calls new PostScript::Simple::EPS with all the default options. To
change these, call it yourself as below, rather than using this method.

  $eps = new PostScript::Simple::EPS(source => $ps->get);

=cut

sub geteps# {{{
{
  my $self = shift;
  my $page;
  my $i;
  my $doc;
  my $eps;
  
  croak "document is not EPS" unless ($$self{eps} == 1);

  $eps = new PostScript::Simple::EPS(source => $self->get);
  return $eps;
}# }}}


=item C<setcolour((red, green, blue)|(name))>

Sets the new drawing colour to the values specified in C<red>, C<green> and
C<blue>. The values range from 0 to 255.

Alternatively, a colour name may be specified. Those currently defined are
listed at the top of the PostScript::Simple module in the C<%pscolours> hash.

Example:

    # set new colour to brown
    $p->setcolour(200,100,0);
    # set new colour to black
    $p->setcolour("black");

=cut

sub setcolour# {{{
{
  my $self = shift;
  my ($r, $g, $b) = @_;

  if ( @_ == 1 )
  {
    $r = lc $r;

    if (defined $pscolours{$r})
    {
      ($r, $g, $b) = split(/\s+/, $pscolours{$r});
    } else {
      $self->_error( "bad colour name '$r'" );
      return 0;
    }
  }
  elsif ( @_ == 3 )
  {
    $r /= 255;
    $g /= 255;
    $b /= 255;
  }
  else
  {
    if (not defined $r) { $r = 'undef' }
    if (not defined $g) { $g = 'undef' }
    if (not defined $b) { $b = 'undef' }
    $self->_error( "setcolour given invalid arguments: $r, $g, $b" );
    return 0;
  }

  if ($self->{colour})
  {
    $self->{pspages} .= "$r $g $b setrgbcolor\n";
  } else {
    $r = 0.3*$r + 0.59*$g + 0.11*$b;	##PKENT - better colour->grey conversion
    $self->{pspages} .= "$r setgray\n";
  }
  
  return 1;
}# }}}


=item C<setlinewidth(width)>

Sets the new line width to C<width> units.

Example:

    # draw a line 10mm long and 4mm wide
    $p = new PostScript::Simple(units => "mm");
    $p->setlinewidth(4);
    $p->line(10,10, 20,10);

=cut


sub setlinewidth# {{{
{
  my $self = shift;
  my $width = shift || do {
    $self->_error( "setlinewidth not given a width" ); return 0;
  };

# MCN should allow for option units=>"cm" on each setlinewidth / line / polygon etc
  ##PKENT - good idea, should we have names for line weights, like we do for colours?
  if ($width eq "thin") { $width = "0.4" }
  else { $width .= " u" }

  $self->{pspages} .= "$width setlinewidth\n";
  
  return 1;
}# }}}


=item C<line(x1,y1, x2,y2 [,red, green, blue])>

Draws a line from the co-ordinates (x1,x2) to (x2,y2). If values are specified
for C<red>, C<green> and C<blue>, then the colour is set before the line is drawn.

Example:

    # set the colour to black
    $p->setcolour("black");

    # draw a line in the current colour (black)
    $p->line(10,10, 10,20);
    
    # draw a line in red
    $p->line(20,10, 20,20, 255,0,0);

    # draw another line in red
    $p->line(30,10, 30,20);

=cut


sub line# {{{
{
  my $self = shift;
  my ($x1, $y1, $x2, $y2, $r, $g, $b) = @_;
# dashed lines? XXXXX

# MCN should allow for option units=>"cm" on each setlinewidth / line / polygon etc
  if ((!$self->{pspagecount}) and (!$self->{eps}))
  {
# Cannot draw on to non-page when not an eps file XXXXX
    return 0;
  }

  if ( @_ == 7 )
  {
    $self->setcolour($r, $g, $b);
  }
  elsif ( @_ != 4 )
  {
  	$self->_error( "wrong number of args for line" );
  	return 0;
  }
  
  $self->newpath;
  $self->moveto($x1, $y1);
  $self->{pspages} .= "$x2 ux $y2 uy lineto stroke\n";
  
  return 1;
}# }}}


=item C<linextend(x,y)>

Assuming the previous command was C<line>, C<linextend>, C<curve> or
C<curvextend>, extend that line to include another segment to the co-ordinates
(x,y). Behaviour after any other method is unspecified.

Example:

    $p->line(10,10, 10,20);
    $p->linextend(20,20);
    $p->linextend(20,10);
    $p->linextend(10,10);

Notes

The C<polygon> method may be more appropriate.

=cut


sub linextend# {{{
{
  my $self = shift;
  my ($x, $y) = @_;
  
  unless ( @_ == 2 )
  {
    $self->_error( "wrong number of args for linextend" );
  	return 0;
  }
  
  $self->{pspages} =~ s/eto stroke\n$/eto\n$x ux $y uy lineto stroke\n/;
  
  ##PKENT comments: lineto can follow a curveto or a lineto, hence the change in regexp
  ##also I thought that it'd be better to change the '.*$' in the regexp with '\n$' - perhaps
  ##we need something like $self->{_lastcommand} to know if operations are valid?
    
#  $self->{pspages} .= "$x ux $y uy lineto stroke\n";
# XXXXX fixme

  return 1;
}# }}}

=item C<arc([options,] x,y, radius, start_angle, end_angle)>

Draws an arc on the circle of radius C<radius> with centre (C<x>,C<y>). The arc
starts at angle C<start_angle> and finishes at C<end_angle>. Angles are specified
in degrees, where 0 is at 3 o'clock, and the direction of travel is anti-clockwise.

Any options are passed in a hash reference as the first parameter. The available
option is:

=over 4

=item filled => 1

If C<filled> is 1 then the arc will be filled in.

=back

Example:

    # semi-circle
    $p->arc(10, 10, 5, 0, 180);

    # complete filled circle
    $p->arc({filled=>1}, 30, 30, 10, 0, 360);

=cut

sub arc# {{{
{
  my $self = shift;
  my %opt = ();

  if (ref($_[0])) {
    %opt = %{; shift};
  }

  if ((!$self->{pspagecount}) and (!$self->{eps})) {
# Cannot draw on to non-page when not an eps file XXXXX
    return 0;
  }

  my ($x, $y, $r, $sa, $ea) = @_;

  unless (@_ == 5) {
    $self->_error("arc: wrong number of arguments");
    return 0;
  }

  $self->newpath;
  $self->{pspages} .= "$x ux $y uy $r u $sa $ea arc ";
  if ($opt{'filled'}) {
    $self->{pspages} .= "fill\n"
  } else {
    $self->{pspages} .= "stroke\n"
  }
  
  return 1;
}# }}}

=item C<polygon([options,] x1,y1, x2,y2, ..., xn,yn)>

The C<polygon> method is multi-function, allowing many shapes to be created and
manipulated. Polygon draws lines from (x1,y1) to (x2,y2) and then from (x2,y2) to
(x3,y3) up to (xn-1,yn-1) to (xn,yn).

Any options are passed in a hash reference as the first parameter. The available
options are as follows:

=over 4

=item rotate => angle
=item rotate => [angle,x,y]

Rotate the polygon by C<angle> degrees anti-clockwise. If x and y are specified
then use the co-ordinate (x,y) as the centre of rotation, otherwise use the
co-ordinate (x1,y1) from the main polygon.

=item filled => 1

If C<filled> is 1 then the PostScript output is set to fill the object rather
than just draw the lines.

=item offset => [x,y]

Displace the object by the vector (x,y).

=back

Example:

    # draw a square with lower left point at (10,10)
    $p->polygon(10,10, 10,20, 20,20, 20,10, 10,10);

    # draw a filled square with lower left point at (20,20)
    $p->polygon( {offset => [10,10], filled => 1},
                10,10, 10,20, 20,20, 20,10, 10,10);

    # draw a filled square with lower left point at (10,10)
    # rotated 45 degrees (about the point (10,10))
    $p->polygon( {rotate => 45, filled => 1},
                10,10, 10,20, 20,20, 20,10, 10,10);

=cut


sub polygon# {{{
{
  my $self = shift;

  my %opt = ();
  my ($xoffset, $yoffset) = (0,0);
  my ($rotate, $rotatex, $rotatey) = (0,0,0);

# PKENT comments - the first arg could be an optional hashref of options. See if
# it's there with ref($_[0]) If it is, then shift it off and use those options.
# Could take the form: polygon( { offset => [ 10, 10 ], filled => 0, rotate =>
# 45, rotate => [45, 10, 10] }, $x1, ...  it seems neater to use perl native
# structures instead of manipulating strings
# ... done MCN 2002-10-22

  if ($#_ < 3)
  {
# cannot have polygon with just one point...
    $self->_error( "bad polygon - not enough points" );
    return 0;
  }

  if (ref($_[0]))
  {
    %opt = %{; shift};
  }

  my $x = shift;
  my $y = shift;

  if (defined $opt{'rotate'})
  {
    if (ref($opt{'rotate'}))
    {
      ($rotate, $rotatex, $rotatey) = @{$opt{'rotate'}};
    }
    else
    {
      ($rotate, $rotatex, $rotatey) = ($opt{'rotate'}, $x, $y);
    }
  }

  if (defined $opt{'offset'})
  {
    if (ref($opt{'offset'}))
    {
      ($xoffset, $yoffset) = @{$opt{'offset'}};
    }
    else
    {
      $self->_error("polygon: bad offset option" );
      return 0;
    }
  }

  if (!defined $opt{'filled'})
  {
    $opt{'filled'} = 0;
  }
  
  unless (defined($x) && defined($y))
  {
    $self->_error("polygon: no start point");
    return 0;
  }

  my $savestate = ($xoffset || $yoffset || $rotate) ? 1 : 0 ;
  
  if ( $savestate )
  {
    $self->{pspages} .= "gsave ";
  }

  if ($xoffset || $yoffset)
  {
    $self->{pspages} .= "$xoffset ux $yoffset uy translate\n";
    #$self->{pspages} .= "$xoffset u $yoffset u translate\n";   ?
  }

  if ($rotate)
  {
    if (!$self->{usedrotabout})
    {
      $self->{psfunctions} .= "/rotabout {3 copy pop translate rotate exch 0 exch
sub exch 0 exch sub translate} def\n";
      $self->{usedrotabout} = 1;
    }

    $self->{pspages} .= "$rotatex ux $rotatey uy $rotate rotabout\n";
#    $self->{pspages} .= "gsave $rotatex ux $rotatey uy translate ";
#    $self->{pspages} .= "$rotate rotate -$rotatex ux -$rotatey uy translate\n";
  }
  
  $self->newpath;
  $self->moveto($x, $y);
  
  while ($#_ > 0)
  {
    my $x = shift;
    my $y = shift;
    
    $self->{pspages} .= "$x ux $y uy lineto ";
  }

  if ($opt{'filled'})
  {
    $self->{pspages} .= "fill\n";
  }
  else
  {
    $self->{pspages} .= "stroke\n";
  }

  if ( $savestate )
  {
    $self->{pspages} .= "grestore\n";
  }
  
  return 1;
}# }}}


=item C<circle([options,] x,y, r)>

Plot a circle with centre at (x,y) and radius of r.

There is only one option.

=over 4

=item filled => 1

If C<filled> is 1 then the PostScript output is set to fill the object rather
than just draw the lines.

=back

Example:

    $p->circle(40,40, 20);
    $p->circle( {filled => 1}, 62,31, 15);

=cut


sub circle# {{{
{
  my $self = shift;
  my %opt = ();

  if (ref($_[0]))
  {
    %opt = %{; shift};
  }

  my ($x, $y, $r) = @_;

  unless (@_ == 3)
  {
    $self->_error("circle: wrong number of arguments");
    return 0;
  }

  if (!$self->{usedcircle})
  {
    $self->{psfunctions} .= "/circle {newpath 0 360 arc closepath} bind def\n";
    $self->{usedcircle} = 1;
  }

  $self->{pspages} .= "$x ux $y uy $r u circle ";
  if ($opt{'filled'}) { $self->{pspages} .= "fill\n" }
  else {$self->{pspages} .= "stroke\n" }
  
  return 1;
}# }}}

=item C<circletext([options,] x, y, r, a, text)>

Draw text in an arc centered about angle C<a> with circle midpoint (C<x>,C<y>)
and radius C<r>.

There is only one option.

=over 4

=item align => "alignment"

C<alignment> can be 'inside' or 'outside'. The default is 'inside'.

=back

Example:

    # outside the radius, centered at 90 degrees from the origin
    $p->circletext(40, 40, 20, 90, "Hello, Outside World!");
    # inside the radius centered at 270 degrees from the origin
    $p->circletext( {align => "inside"}, 40, 40, 20, 270, "Hello, Inside World!");

=cut


sub circletext# {{{
{
  my $self = shift;
  my %opt = ();

  if (ref($_[0]))
  {
    %opt = %{; shift};
  }

  my ($x, $y, $r, $a, $text) = @_;

  unless (@_ == 5) {
    $self->_error("circletext: wrong number of arguments");
    return 0;
  }

  unless (defined $self->{lastfontsize}) {
    $self->_error("circletext: must set font first");
    return 0;
  }

  if (!$self->{usedcircletext}) {
    $self->{psfunctions} .= <<'EOCT';
/outsidecircletext
  { $circtextdict begin
      /radius exch def
      /centerangle exch def
      /ptsize exch def
      /str exch def
      /xradius radius ptsize 4 div add def
      gsave
        centerangle str findhalfangle add rotate
        str { /charcode exch def ( ) dup 0 charcode put outsideshowcharandrotate } forall
      grestore
    end
  } def
       
/insidecircletext
  { $circtextdict begin
      /radius exch def
      /centerangle exch def
      /ptsize exch def
      /str exch def
      /xradius radius ptsize 3 div sub def
      gsave
        centerangle str findhalfangle sub rotate
        str { /charcode exch def ( ) dup 0 charcode put insideshowcharandrotate } forall
      grestore
    end
  } def
/$circtextdict 16 dict def
$circtextdict begin
  /findhalfangle
    { stringwidth pop 2 div 2 xradius mul pi mul div 360 mul
    } def
  /outsideshowcharandrotate
    { /char exch def
      /halfangle char findhalfangle def
      gsave
        halfangle neg rotate radius 0 translate -90 rotate
        char stringwidth pop 2 div neg 0 moveto char show
      grestore
      halfangle 2 mul neg rotate
    } def
  /insideshowcharandrotate
    { /char exch def
      /halfangle char findhalfangle def
      gsave
        halfangle rotate radius 0 translate 90 rotate
        char stringwidth pop 2 div neg 0 moveto char show
      grestore
      halfangle 2 mul rotate
    } def
  /pi 3.1415926 def
end
EOCT
    $self->{usedcircletext} = 1;
  }

  $self->{pspages} .= "gsave\n";
  $self->{pspages} .= "  $x ux $y uy translate\n";
  $self->{pspages} .= "  ($text) $self->{lastfontsize} $a $r u ";
  if ($opt{'align'} && ($opt{'align'} eq "outside")) {
    $self->{pspages} .= "outsidecircletext\n";
  } else {
    $self->{pspages} .= "insidecircletext\n";
  }
  $self->{pspages} .= "grestore\n";
  
  return 1;
}# }}}

=item C<box(x1,y1, x2,y2 [, options])>

Draw a rectangle from lower left co-ordinates (x1,y1) to upper right
co-ordinates (y1,y2).

Options are:

=over 4

=item filled => 1

If C<filled> is 1 then fill the rectangle.

=back

Example:

    $p->box(10,10, 20,30);
    $p->box( {filled => 1}, 10,10, 20,30);

Notes

The C<polygon> method is far more flexible, but this method is quicker!

=cut


sub box# {{{
{
  my $self = shift;

  my %opt = ();

  if (ref($_[0]))
  {
    %opt = %{; shift};
  }

  my ($x1, $y1, $x2, $y2) = @_;

  unless (@_ == 4) {
  	$self->_error("box: wrong number of arguments");
  	return 0;
  }

  if (!defined($opt{'filled'}))
  {
    $opt{'filled'} = 0;
  }
  
  unless ($self->{usedbox})
  {
    $self->{psfunctions} .= "/box {
  newpath 3 copy pop exch 4 copy pop pop
  8 copy pop pop pop pop exch pop exch
  3 copy pop pop exch moveto lineto
  lineto lineto pop pop pop pop closepath
} bind def
";
    $self->{usedbox} = 1;
  }

  $self->{pspages} .= "$x1 ux $y1 uy $x2 ux $y2 uy box ";
  if ($opt{'filled'}) { $self->{pspages} .= "fill\n" }
  else {$self->{pspages} .= "stroke\n" }

  return 1;
}# }}}


=item C<setfont(font, size)>

Set the current font to the PostScript font C<font>. Set the size in PostScript
points to C<size>.

Notes

This method must be called on every page before the C<text> method is used.

=cut


sub setfont# {{{
{
  my $self = shift;
  my ($name, $size, $ysize) = @_;

  unless (@_ == 2) {
  	$self->_error( "wrong number of arguments for setfont" );
  	return 0;
  }

# set font y size XXXXX
  $self->{pspages} .= "/$name findfont $size scalefont setfont\n";

  $self->{lastfontsize} = $size;

  return 1;
}# }}}


=item C<text([options,] x,y, string)>

Plot text on the current page with the lower left co-ordinates at (x,y) and 
using the current font. The text is specified in C<string>.

Options are:

=over 4

=item align => "alignment"

alignment can be 'left', 'centre' or 'right'. The default is 'left'.

=item rotate => angle

"rotate" degrees of rotation, defaults to 0 (i.e. no rotation).
The angle to rotate the text, in degrees. Centres about (x,y) and rotates
clockwise. (?). Default 0 degrees.

=back

Example:

    $p->setfont("Times-Roman", 12);
    $p->text(40,40, "The frog sat on the leaf in the pond.");
    $p->text( {align => 'centre'}, 140,40, "This is centered.");
    $p->text( {rotate => 90}, 140,40, "This is rotated.");
    $p->text( {rotate => 90, align => 'centre'}, 140,40, "This is both.");

=cut


sub text# {{{
{
  my $self = shift;

  my $rot = "";
  my $rot_m = "";
  my $align = "";
  my %opt = ();

  if (ref($_[0]))
  {
    %opt = %{; shift};
  }
  
  unless ( @_ == 3 )
  { # check required params first
  	$self->_error("text: wrong number of arguments");
  	return 0;
  }
  
  my ($x, $y, $text) = @_;

  unless (defined($x) && defined($y) && defined($text))
  {
  	$self->_error("text: wrong number of arguments");
  	return 0;
  }
  
  # Escape text to allow parentheses
  $text =~ s|([\\\(\)])|\\$1|g;
  $text =~ s/([\x00-\x1f\x7f-\xff])/sprintf('\\%03o',ord($1))/ge;

  $self->newpath;
  $self->moveto($x, $y);

  # rotation

  if (defined $opt{'rotate'})
  {
    my $rot_a = $opt{ 'rotate' };
    if( $rot_a != 0 )
    {
      $rot   = " $rot_a rotate ";
      $rot_a = -$rot_a;
      $rot_m = " $rot_a rotate ";
    };
  }

  # alignment
  $align = " show stroke"; 
      # align left
  if (defined $opt{'align'})
  {
    $align = " dup stringwidth pop neg 0 rmoveto show" 
        if $opt{ 'align' } eq 'right';
    $align = " dup stringwidth pop 2 div neg 0 rmoveto show"
        if $opt{ 'align' } eq 'center' or $opt{ 'align' } eq 'centre';
  }
  
  $self->{pspages} .= "($text) $rot $align $rot_m\n";

  return 1;
}# }}}


=item curve( x1, y1, x2, y2, x3, y3, x4, y4 )

Create a curve from (x1, y1) to (x4, y4). (x2, y2) and (x3, y3) are the
control points for the start- and end-points respectively.

=cut


sub curve# {{{
{
  my $self = shift;
  my ($x1, $y1, $x2, $y2, $x3, $y3, $x4, $y4) = @_;
# dashed lines? XXXXX

  unless ( @_ == 8 ) 
  {
    $self->_error( "bad curve definition, wrong number of args" );
    return 0;
  }
  
  if ((!$self->{pspagecount}) and (!$self->{eps}))
  {
# Cannot draw on to non-page when not an eps file XXXXX
    return 0;
  }

  $self->newpath;
  $self->moveto($x1, $y1);
  $self->{pspages} .= "$x2 ux $y2 uy $x3 ux $y3 uy $x4 ux $y4 uy curveto stroke\n";

  return 1;
}# }}}


=item curvextend( x1, y1, x2, y2, x3, y3 )

Assuming the previous command was C<line>, C<linextend>, C<curve> or
C<curvextend>, extend that path with another curve segment to the co-ordinates
(x3, y3). (x1, y1) and (x2, y2) are the control points.  Behaviour after any
other method is unspecified.

=cut


sub curvextend# {{{
{
  my $self = shift;
  my ($x1, $y1, $x2, $y2, $x3, $y3) = @_;
  unless ( @_ == 6 ) 
  {
    $self->_error( "bad curvextend definition, wrong number of args" );
    return 0;
  }
  
  # curveto may follow a lineto etc...
  $self->{pspages} =~ s/eto stroke\n$/eto\n$x1 ux $y1 uy $x2 ux $y2 uy $x3 ux $y3 uy curveto stroke\n/;
  
  return 1;
}# }}}


=item newpath

This method is used internally to begin a new drawing path - you should generally NEVER use it.

=cut


sub newpath# {{{
{
	my $self = shift;
	$self->{pspages} .= "newpath\n";
	return 1;
}# }}}


=item moveto( x, y )

This method is used internally to move the cursor to a new point at (x, y) - you will 
generally NEVER use this method.

=cut


sub moveto# {{{
{
	my $self = shift;
	my ($x, $y) = @_;
	$self->{pspages} .= "$x ux $y uy moveto\n";
	return 1;
}# }}}


=item C<importepsfile([options,] filename, x1,y1, x2,y2)>

Imports an EPS file and scales/translates its bounding box to fill
the area defined by lower left co-ordinates (x1,y1) and upper right
co-ordinates (x2,y2). By default, if the co-ordinates have a different
aspect ratio from the bounding box, the scaling is constrained on the
greater dimension to keep the EPS fully inside the area.

Options are:

=over 4

=item overlap => 1

If C<overlap> is 1 then the scaling is calculated on the lesser dimension
and the EPS can overlap the area.

=item stretch => 1

If C<stretch> is 1 then fill the entire area, ignoring the aspect ratio.
This option overrides C<overlap> if both are given.

=back

Example:

    # Assume smiley.eps is a round smiley face in a square bounding box

    # Scale it to a (10,10)(20,20) box
    $p->importepsfile("smiley.eps", 10,10, 20,20);

    # Keeps aspect ratio, constrained to smallest fit
    $p->importepsfile("smiley.eps", 10,10, 30,20);

    # Keeps aspect ratio, allowed to overlap for largest fit
    $p->importepsfile( {overlap => 1}, "smiley.eps", 10,10, 30,20);

    # Aspect ratio is changed to give exact fit
    $p->importepsfile( {stretch => 1}, "smiley.eps", 10,10, 30,20);

=cut


sub importepsfile# {{{
{
  my $self = shift;

  my $bbllx;
  my $bblly;
  my $bburx;
  my $bbury;
  my $bbw;
  my $bbh;
  my $pagew;
  my $pageh;
  my $scalex;
  my $scaley;
  my $line;
  my $eps;

  my %opt = ();

  if (ref($_[0])) {
    %opt = %{; shift};
  }

  my ($file, $x1, $y1, $x2, $y2) = @_;

  unless (@_ == 5) {
    $self->_error("importepsfile: wrong number of arguments");
    return 0;
  }

  $opt{'overlap'} = 0 if (!defined($opt{'overlap'}));
  $opt{'stretch'} = 0 if (!defined($opt{'stretch'}));
  
  $eps = new PostScript::Simple::EPS(file => $file);
  ($bbllx, $bblly, $bburx, $bbury) = $eps->get_bbox();

  $pagew = $x2 - $x1;
  $pageh = $y2 - $y1;

  $bbw = $bburx - $bbllx;
  $bbh = $bbury - $bblly;

  if (($bbw == 0) || ($bbh == 0)) {
    $self->_error("importeps: Bounding Box has zero dimension");
    return 0;
  }

  $scalex = $pagew / $bbw;
  $scaley = $pageh / $bbh;

  if ($opt{'stretch'} == 0) {
    if ($opt{'overlap'} == 0) {
      if ($scalex > $scaley) {
        $scalex = $scaley;
      } else {
        $scaley = $scalex;
      }
    } else {
      if ($scalex > $scaley) {
        $scaley = $scalex;
      } else {
        $scalex = $scaley;
      }
    }
  }

  $eps->scale($scalex, $scaley);
  $eps->translate(-$bbllx, -$bblly);
  $self->_add_eps($eps, $x1, $y1);

  return 1;
}# }}}


=item C<importeps(filename, x,y)>

Imports a PostScript::Simple::EPS object into the current document at position
C<(x,y)>.

Example:

    use PostScript::Simple;
    
    # create a new PostScript object
    $p = new PostScript::Simple(papersize => "A4",
                                colour => 1,
                                units => "in");
    
    # create a new page
    $p->newpage;
    
    # create an eps object
    $e = new PostScript::Simple::EPS(file => "test.eps");
    $e->rotate(90);
    $e->scale(0.5);

    # add eps to the current page
    $p->importeps($e, 10,50);

=cut


sub importeps# {{{
{
  my $self = shift;
  my ($epsobj, $xpos, $ypos) = @_;

  unless (@_ == 3) {
    $self->_error("importeps: wrong number of arguments");
    return 0;
  }

  $self->_add_eps($epsobj, $xpos, $ypos);

  return 1;
}# }}}

sub _add_eps# {{{
{
  my $self = shift;
  my $epsobj;
  my $xpos;
  my $ypos;

  if (ref($_[0]) ne "PostScript::Simple::EPS") {
    croak "internal error: _add_eps[0] must be eps object";
  }

  if ((!$self->{pspagecount}) and (!$self->{eps})) {
    # Cannot draw on to non-page when not an eps file
    $self->_error("importeps: no current page");
    return 0;
  }

  if ( @_ != 3 ) {
  	croak "internal error: wrong number of arguments for _add_eps";
  	return 0;
  }

  unless ($self->{usedimporteps}) {
    $self->{psfunctions} .= <<'EOEPS';
/BeginEPSF { /b4_Inc_state save def /dict_count countdictstack def
/op_count count 1 sub def userdict begin /showpage { } def 0 setgray
0 setlinecap 1 setlinewidth 0 setlinejoin 10 setmiterlimit [ ]
0 setdash newpath /languagelevel where { pop languagelevel 1 ne {
false setstrokeadjust false setoverprint } if } if } bind def
/EndEPSF { count op_count sub {pop} repeat countdictstack dict_count
sub {end} repeat b4_Inc_state restore } bind def
EOEPS
    $self->{usedimporteps} = 1;
  }

  ($epsobj, $xpos, $ypos) = @_;

  $self->{pspages} .= "BeginEPSF\n";
  $self->{pspages} .= "$xpos ux $ypos uy translate\n";
  $self->{pspages} .= "1 ux 1 uy scale\n";
  $self->{pspages} .= $epsobj->_get_include_data($xpos, $ypos);
  $self->{pspages} .= "EndEPSF\n";
  
  return 1;
}# }}}


### PRIVATE

sub _error {# {{{
	my $self = shift;
	my $msg = shift;
	$self->{pspages} .= "(error: $msg\n) print flush\n";
}# }}}


# Display method for debugging internal variables
#
#sub display {
#  my $self = shift;
#  my $i;
#
#  foreach $i (keys(%{$self}))
#  {
#    print "$i = $self->{$i}\n";
#  }
#}

=back

=head1 BUGS

Some current functionality may not be as expected, and/or may not work correctly.
That's the fun with using code in development!

=head1 AUTHOR

The PostScript::Simple module was created by Matthew Newton, with ideas
and suggestions from Mark Withall and many other people from around the world.
Thanks!

Please see the README file in the distribution for more information about
contributors.

Copyright (C) 2002-2003 Matthew C. Newton / Newton Computing

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, version 2.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU General Public License for more details,
available at http://www.gnu.org/licenses/gpl.html.

=head1 SEE ALSO

L<PostScript::Simple::EPS>

=cut

1;

# vim:foldmethod=marker:
