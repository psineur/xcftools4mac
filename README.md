xcfinfo2plist
=========================
Simple wrap around for xcfinfo to output data as a dictionary in plist file format.   
Inverts the Y coordinate of the layer position, since in Gimp (0,0) is at the top left corner.   
Bottom Layer is First in the Layers array.

Usage:

    xcfinfo2plist input.xcf output.plist

Xcftools by Henning Makholm
=====================

Xcftools is a set of fast command-line tools for extracting information from the Gimp's native file format XCF. The tools are designed to allow efficient use of layered XCF files as sources in a build system that use 'make' and similar tools to manage automatic processing of the graphics. These tools work independently of the Gimp engine and do not require the Gimp to even be installed.

* xcf2pnm
converts XCF files to ppm, pgm or pbm formats, flattening layers if necessary. If the image contains transparency, an alpha map can be written to a separate file, or a background color can be specified on the command line.

* xcf2png
converts XCF files to PNG format, flattening layers if necessary. Transparency can either be left in the image, or a background color provided on the command line.

* xcfinfo
lists information about layers in an XCF file.
The tools can either flatten the XCF file as given, or extract specific layers named on the command line.

Xcftools was written by Henning Makholm <henning@makholm.net>   
Sources at http://henning.makholm.net/xcftools/, and also in Debian starting with the "etch" release.   
It is hereby in the public domain.
