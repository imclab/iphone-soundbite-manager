//
//  libraryManager.m
//  audioPlayer
//
//  Created by Aaron Leese on 6/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "libraryManager.h"
#import "audioPlayerAppDelegate.h"

/// LIBARY ::::::::::::::::::::::::::::::::::: 
////////////////////////////////////////////////////////////////
@implementation libraryManager

-(id) init
{
	
	NSString *libFile = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Library"];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:libFile];
	
	if (fileExists)
	{
		libraryArray = [[NSMutableDictionary alloc] initWithContentsOfFile:libFile];
	}
	else
	{
		libraryArray = [[NSMutableDictionary alloc] init];
	}
	
	[self refreshLibrary]; 
	
	currentSoundbite = 0;
	
	currentGroup = @"";
	
	return self;
	
}


// :::::: reading the library XML
////////////////////////////////////////////////////////////////
- (void) refreshLibrary { 
	
	[libraryArray removeAllObjects]; // clear ....
	[self updateLibrary]; // get from online .....
	return;
	
	// *** OLD ***** method below ... which just looked for files in the local directories ....
	
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
- (void) updateLibrary {
	
	NSLog(@"checking online for new soundbites ....");
	
	// CHECK ONLINE for new soundbites  ::::::::::::::::::::::::::::
	///////////////////////////////////////////////////////////////////////
	//NSString *const URL = @"http://www.flyloops.com/iphone/test10.xml";
	
	NSString *URL = @"http://www.flyloops.com/iphone/index.php?viewNew=1&user=1";
	NSURL* url = [NSURL URLWithString:URL];
	
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];

	[request setDelegate:self];
	[request setDidFinishSelector:@selector(requestFinished:)];
	[request setDidFailSelector:@selector(requestFailed:)];
	[request startAsynchronous];
	
    
	//NSData *returnData = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	//[NSURLConnection sendSynchronousRequest:req returningResponse: nil error: nil];
    
	//NSString *html = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
	
}
//////////////// Parsing the XML
- (void) parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI 
  qualifiedName:(NSString *)qualifiedName 
	 attributes:(NSDictionary *)attributeDict
{
    
	NSLog(@"Started parsing %@", elementName); 	
	
	if([elementName isEqualToString:@"question"]) 
	{
		
		//Extract the attribute here.
		NSString *fileName = [attributeDict objectForKey:@"name"]; 
		NSString *answerFileName = [attributeDict objectForKey:@"answer"]; 
		NSString *questionSet =  [attributeDict objectForKey:@"questionSet"]; 
		NSString *comments =  [attributeDict objectForKey:@"comments"]; 
		NSString *questionID =  [attributeDict objectForKey:@"id"]; 
		
		NSLog(@"filename: %@", [attributeDict objectForKey:@"name"]);
		
		
		// intuit the path from the filename for now ....
		NSString *remotePath = @"http://www.flyloops.com/iphone/questions/";
		NSString *remotePathFull = [remotePath stringByAppendingString:fileName];
		NSURL *newItemURL = [NSURL URLWithString:remotePathFull];
		NSLog(@"url: %@", newItemURL);
		
		// Local path
		NSString *appDirectory = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
		NSString *docDirectory  = [appDirectory stringByAppendingString:@"/Documents/"];
		NSString *questionPath = [docDirectory stringByAppendingString:fileName];
		NSLog(@"local path: %@", questionPath);
		
		// if this is a question that is not in the local library already, download and add it ....
		if ([[questionPath pathExtension] isEqualToString: @"wav"] || [[questionPath pathExtension] isEqualToString: @"caf"])
		{
			// DOWNLOAD 
			audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
			[appDelegate triggerDownload:newItemURL];
			
			
			// ::::: ADD it to the LIBRARY 
			///////////////////////////////////////////////////
			
			// create a new soundbite ...
			SoundBite *QorA = [[SoundBite alloc] init];
			NSLog(@"setting string %@", fileName);
			QorA.fileName = [fileName copy];
			QorA.set = [questionSet copy];
			QorA.sqlID = [questionID copy];
			QorA.comments = [comments copy];	
			QorA.answerFile = [answerFileName copy];			
			
			// Pull up the appropriate question set (array) and add this
			// note *** if this is an answer ... the "questionset" is the questionID it maps too .....
			NSMutableArray *tempArray = [[NSMutableArray alloc] init];
			[tempArray addObjectsFromArray:[libraryArray objectForKey:questionSet]];
			[tempArray addObject:QorA];
			[libraryArray setObject:tempArray forKey:questionSet];
			[tempArray release];
			
			
			NSString *URL = [@"http://www.flyloops.com/iphone/index.php?questionNum=" stringByAppendingString:questionID];
			NSURL* url = [NSURL URLWithString:URL];

			
			// ping the web app, note that this question has been recieved ....
			
			//ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
			//[request startAsynchronous];
			
			
		}
		
		if (answerFileName == NULL) return;
		else if ([answerFileName length] == 0) return;
		else NSLog(@"question has been answered: %@", answerFileName);
		
		// handle ANSWER
		NSString *answerPath = [docDirectory stringByAppendingString:answerFileName];
		NSLog(@"local path: %@", answerPath);
		
		// if this is a question that is not in the local library already, download and add it ....
		if ([[answerPath pathExtension] isEqualToString: @"wav"] || [[answerPath pathExtension] isEqualToString: @"caf"])
		{
			// DOWNLOAD 
			audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
			[appDelegate triggerDownload:newItemURL];
			
			// ::::: ADD it to the LIBRARY 
			///////////////////////////////////////////////////
			
			
			// get the appropriate question from the Library, and set it's answer .....
		
			
			
			/*
			// create a new soundbite ...
			SoundBite *QorA = [[SoundBite alloc] init];
			NSLog(@"setting string %@", answerFileName);
			QorA.answerFile = [answerFileName copy];
			//QorA.set = [questionSet copy];
			//QorA.set = [questionSet copy];
			//QorA.sqlID = [questionID copy];
			
			
			// Pull up the appropriate question set (array) and add this
			// note *** if this is an answer ... the "questionset" is the questionID it maps too .....
			NSMutableArray *tempArray = [[NSMutableArray alloc] init];
			[tempArray addObjectsFromArray:[libraryArray objectForKey:questionSet]];
			[tempArray addObject:QorA];
			[libraryArray setObject:tempArray forKey:questionSet];
			[tempArray release];
			
			
			// for now, assume this downloads correctly ... and ping the server that i has been recieved 
			NSString* docDirectory  = [appDirectory stringByAppendingString:@"/Documents/"];
			
			NSString *URL = [@"http://www.flyloops.com/iphone/index.php?questionNum=" stringByAppendingString:questionID];
			NSURL* url = [NSURL URLWithString:URL];
			
			
			// ping the web app, note that this question has been recieved ....
			
			//ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
			//[request startAsynchronous];
			 */
			
		}
		
		
	}		
	
	
}


// :::::: Connectivity stuff 
////////////////////////////////////////////////////////////////
- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    // response contains the data returned from the server.
	
	NSLog(@"%@", response);
	
	//NSData *xmlData = [NSData response];
	NSData *xmlData = [response dataUsingEncoding:NSUTF8StringEncoding];

	NSXMLParser* parser = [[NSXMLParser alloc] initWithData:xmlData];
	
	[parser setDelegate:self];
	[parser parse];
	
}
- (void) requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    // Do something with the error.
}

// :::::: Library management
////////////////////////////////////////////////////////////////
- (NSArray*) getCurrentQuestionGroupArray
{
	// if we are at the root node ...
	if ([currentGroup length] == 0) // if the string is empty, show all groups ....
	{
		//NSArray* test = [libraryArray allKeys];

		NSMutableArray *keys;
		keys = [[NSMutableArray alloc] initWithCapacity: [[libraryArray allKeys] count]];
		[keys addObjectsFromArray:[libraryArray allKeys]]; 		
		
		return keys; 
		// Aaron - memory leak ??
	}
	else // return an array showing just this Question Group ...
	{
		NSLog(@"key %@", currentGroup);
		
		NSMutableArray *currentSoundbites = [[NSMutableArray alloc] init];
		[currentSoundbites addObjectsFromArray:[libraryArray objectForKey:currentGroup]]; 		
		
		// reduce to a list f filenames .....
		NSMutableArray* fileNames;
		fileNames = [[NSMutableArray alloc] init];
		for (SoundBite *soundBite in currentSoundbites) {
		 	NSLog(@" fileName: %@", [soundBite fileName]);
			[fileNames addObject:[soundBite fileName]];
		}
		
		return fileNames;
	}
	
	
	
} 
-(void) saveLibrary
{
	NSString *libFile = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Library"];
	[libraryArray writeToFile:libFile atomically:YES]; 	
	
}

- (NSMutableArray*)getCurrentSoundBiteArray
{
	
	NSMutableArray *currentSoundbites = [[NSMutableArray alloc] init];
	[currentSoundbites addObjectsFromArray:[libraryArray objectForKey:currentGroup]]; 		
	
	return currentSoundbites;
	
}

- (SoundBite*) getCurrentSoundBite
{
	return currentSoundbite;
}

- (void) setCurrentSoundbite:(SoundBite*) newCurrentSoundbite
{
	NSLog(@"new soundbite set - %@", [newCurrentSoundbite comments]);
	currentSoundbite = newCurrentSoundbite;
}


- (NSString*) getCurrentGroup
{
	return currentGroup;
	
}
- (void) setCurrentGroup:(NSString*) newGroup;
{
	currentGroup = newGroup;
}
 

@end
 