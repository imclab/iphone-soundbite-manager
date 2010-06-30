//
//  libraryManager.m
//  audioPlayer
//
//  Created by Aaron Leese on 6/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "libraryManager.h"


@implementation libraryManager

-(id) init
{
	
	NSString *libFile = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Library"];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:libFile];
	
	if (fileExists)
	{
		libraryArray = [[NSMutableArray alloc] initWithContentsOfFile:libFile];
	}
	else
	{
		libraryArray = [[NSMutableArray alloc] init];
	}
	
	return self;
	
}

- (void) updateLibrary
{
	
	NSLog(@"checking online for new soundbites ....");
	
	// CHECK ONLINE for new soundbites  ::::::::::::::::::::::::::::
	///////////////////////////////////////////////////////////////////////
	NSString *const URL = @"http://www.flyloops.com/iphone/test.xml";
	NSURL* url = [NSURL URLWithString:URL];
	NSXMLParser* parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
	
	[parser setDelegate:self];
	[parser parse];
	
}

- (void) refreshLibrary
{ 
	
	[libraryArray removeAllObjects];
	
	NSString* appDirectory = [[NSBundle mainBundle] bundlePath]; // stringByDeletingLastPathComponent];
	NSString *docDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/"];
	
	NSFileManager *filemgr; 
	NSArray *filelist;
	int count;
	int i;
	
	
	filemgr = [NSFileManager defaultManager];
	
	// get files in the documents folder ... 
	filelist = [filemgr directoryContentsAtPath: docDirectory];
	count = [filelist count];
	NSLog (@"%@", docDirectory);
	for (i = 0; i < count; i++)
	{
        NSLog (@"%@", [filelist objectAtIndex: i]);
		
		if ([[[filelist objectAtIndex: i] pathExtension] isEqualToString: @"wav"])
		{
			[libraryArray addObject:[filelist objectAtIndex: i]];
		}
		
	}
	
	// get files in the bundle
	filelist = [filemgr directoryContentsAtPath: appDirectory];
	count = [filelist count];
	NSLog (@"%@", appDirectory);
	for (i = 0; i < count; i++)
	{
        NSLog (@"%@", [filelist objectAtIndex: i]);
		
		if ([[[filelist objectAtIndex: i] pathExtension] isEqualToString: @"wav"])
		{
			[libraryArray addObject:[filelist objectAtIndex: i]];
		}
	}
	
}

- (NSMutableArray*) getLibraryArray
{
	return libraryArray;
}


-(void) saveLibrary
{
	NSString *libFile = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Library"];
	[libraryArray writeToFile:libFile atomically:YES]; 	
	
}


@end
 