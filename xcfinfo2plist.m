/* A program that extracts metadata from an XCF file
 *
 * This file was written by Henning Makholm <henning@makholm.net>
 * It is hereby in the public domain.
 * 
 * In jurisdictions that do not recognise grants of copyright to the
 * public domain: I, the author and (presumably, in those jurisdictions)
 * copyright holder, hereby permit anyone to distribute and use this code,
 * in source code or binary form, with or without modifications. This
 * permission is world-wide and irrevocable.
 *
 * Of course, I will not be liable for any errors or shortcomings in the
 * code, since I give it away without asking any compenstations.
 *
 * If you use or distribute this code, I would appreciate receiving
 * credit for writing it, in whichever way you find proper and customary.
 */

#import "Foundation/Foundation.h"
#import "DebugLog.h"

#include "xcftools.h"
#include <stdlib.h>
#include <string.h>
#include <locale.h>
#if HAVE_GETOPT_H
#include <getopt.h>
#else
#include <unistd.h>
#endif
#ifndef HAVE_GETOPT_LONG
#define getopt_long(argc,argv,optstring,l1,l2) getopt(argc,argv,optstring)
#endif

#include "xcftools-1.0.7/xcfinfo.oi"

static void
usage(FILE *where)
{
	fprintf(where,_("Usage: %s filename.xcf[.gz] outfile.plist \n"),progname) ;

	if( where == stderr ) {
		exit(1);
	}
}

int
main(int argc,char **argv)
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	int i ;
	int option ;
	const char *unzipper = NULL ;
	const char *infile = NULL ;
	const char *outfile = NULL;
	
	setlocale(LC_ALL,"");
	progname = argv[0] ;
	nls_init();
	
	if( argc <= 1 ) gpl_blurb() ;
	
	while( (option=getopt_long(argc,argv,"-"OPTSTRING,longopts,NULL)) >= 0 )
		switch(option) {
#define OPTION(char,long,desc,man) case char:
#include "xcftools-1.0.7/options.i"
			case 1:
				if( infile ) {
					if (outfile)
					{
						FatalGeneric
						(20,_("Only one XCF file per command line, please"));
					}
					else 
					{
						outfile = optarg;
						break;
					}
					
				} else {
					infile = optarg ;
					break ;
				}
			case '?':
				usage(stderr);
			default:
				FatalUnexpected("Getopt(_long) unexpectedly returned '%c'",option);
		}
	if( infile == NULL || outfile == NULL ) {
		usage(stderr);
	}
	
	TinyLog(@"Reading XCF file: %s...", infile);
	read_or_mmap_xcf(infile,unzipper);
	getBasicXcfInfo();
	
	TinyLog(@"Preparing Dictionary...");
	// Add XCF File info
	NSMutableDictionary *documentInfo = [NSMutableDictionary dictionaryWithCapacity: 7];
	[documentInfo setObject: [NSNumber numberWithInt: XCF.version] forKey:@"Version"];
	[documentInfo setObject: [NSNumber numberWithInt: XCF.width]  forKey:@"Width" ];
	[documentInfo setObject: [NSNumber numberWithInt: XCF.height]  forKey:@"Height" ];
	[documentInfo setObject: [NSString stringWithFormat:@"%s",_(showGimpImageBaseType(XCF.type)) ]  forKey:@"Type" ];
	[documentInfo setObject: [NSString stringWithFormat:@"%s",_(showXcfCompressionType(XCF.compression)) ]  forKey:@"Compression" ];
	
	
	// Prepare Layers Array
	NSMutableArray *layers = [NSMutableArray arrayWithCapacity: (NSUInteger)XCF.numLayers ];
	
	for( i = 0 ; i < XCF.numLayers ; ++i)
	{
		NSMutableDictionary *layer = [NSMutableDictionary dictionaryWithCapacity: 10];
		[layer setObject:[NSString stringWithFormat:@"%s",XCF.layers[i].name ] forKey:@"Name"];
		
		[layer setObject: [NSNumber numberWithInt:XCF.layers[i].dim.c.l ] forKey: @"X"];
		[layer setObject: [NSNumber numberWithInt:XCF.height - XCF.layers[i].dim.c.t - XCF.layers[i].dim.height ] forKey: @"Y"]; 
		[layer setObject: [NSNumber numberWithInt:XCF.layers[i].dim.width] forKey: @"Width"];
		[layer setObject: [NSNumber numberWithInt:XCF.layers[i].dim.height] forKey: @"Height"];
		
		[layer setObject:[NSNumber numberWithBool: (XCF.layers[i].isVisible) ? YES : NO] forKey:@"Visible"];
		[layer setObject:[NSNumber numberWithInt: XCF.layers[i].opacity ] forKey:@"Opacity"];		
		
		[layer setObject: [NSString stringWithFormat:@"%s",_(showGimpImageType(XCF.layers[i].type))] forKey: @"Type" ];		
		[layer setObject: [NSString stringWithFormat:@"%s",_(showGimpLayerModeEffects(XCF.layers[i].mode))] forKey: @"Mode"];		
		[layer setObject: [NSNumber numberWithBool: (XCF.layers[i].hasMask) ? YES : NO ] forKey:@"HasMask"];
		
		[layers addObject: layer];
	}
	
	// Add Layer Info to Dict
	[documentInfo setObject: layers forKey:@"Layers"];
	
	// Save to outfile
	NSString *savePath = [NSString stringWithFormat:@"%s", outfile];
	TinyLog(@"Writing Dictionary to %@", savePath);	
	[documentInfo writeToFile:savePath atomically: YES];
	TinyLog(@"Done!");
	
	[pool release];
	return 0;
}
