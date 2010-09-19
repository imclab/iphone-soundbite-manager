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

-(id) init {
	
	NSString *libFile = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Library"];
	BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:libFile];
	
	NSLog(@"file .... %@", libFile);

	if (fileExists)
	{
		libraryArray = [[NSMutableDictionary alloc] initWithContentsOfFile:libFile];
		
		NSLog(@"library file: %@", libraryArray);
		
	}
	else libraryArray = [[NSMutableDictionary alloc] init];
	
	[self refreshLibrary]; 
	
	currentSoundbite = 0;
	
	currentGroup = @"";
	
	return self;
	
}

// :::::: reading the library XML
////////////////////////////////////////////////////////////////
- (void) refreshLibrary { 
	
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
	
	NSString *SQLTimeString = @"0"; 
	
	if ([libraryArray objectForKey:@"updatedTime"] !=  nil)
		SQLTimeString = [libraryArray objectForKey:@"updatedTime"];
	
	NSString *lastUpdateTime = [@"&lastUpdate=" stringByAppendingString:SQLTimeString];
	
	NSLog(@"url: %@", SQLTimeString);

	//NSURL* url = [NSURL URLWithString:[baseURL stringByAppendingString:lastUpdateTime]];
		
	NSString *baseURL = @"http://www.flyloops.com/iphone/index.php?viewNew=1&user=1";
	 

	NSLog(@"url: %@", lastUpdateTime);
	NSLog(@"url: %@", [baseURL stringByAppendingString:lastUpdateTime]);

	NSString *conditionedString = [baseURL stringByAppendingString:[lastUpdateTime stringByReplacingOccurrencesOfString:@" " withString:@"%20"] ];
	
	NSURL* url = [NSURL URLWithString:conditionedString];
	
	NSLog(@"url: %@", url);
	
	
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
	
	// GET time for LAST UPDATE tracking ::::::
	if([elementName isEqualToString:@"updatedTime"]) 
	{
		// save this as the most recent time that this app has been updated 
		NSString *time = [attributeDict objectForKey:@"time"]; 
	
		NSLog(@"setting update time: ");
		
		[libraryArray setObject:time forKey:@"updatedTime"];
		
		
	}
	if([elementName isEqualToString:@"question"]) 
	{
		
		//Extract the attributes here.
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
			QorA.parentQuestionOrSet = [questionSet copy];
			QorA.sqlID = [questionID copy];
			QorA.comments = [comments copy];	
			//QorA.answerFile = [answerFileName copy];			
			
			// Pull up the appropriate question set (array) and add this
			// note *** if this is an answer ... the "questionset" is the questionID it maps too .....
			NSMutableArray *tempArray = [[NSMutableArray alloc] init];
			[tempArray addObjectsFromArray:[libraryArray objectForKey:questionSet]]; // existing set
			[tempArray addObject:[QorA getDictionary]]; // add the new one ....
			[libraryArray setObject:tempArray forKey:questionSet]; // set as the new set ...
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

-(void) saveLibrary {
	
	NSLog(@"saving library file");
	
	NSString *libFile = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/Library"];
	
	NSDictionary *copy = [[NSDictionary alloc] initWithDictionary:libraryArray copyItems:YES];
 
	BOOL worked = [copy writeToFile:libFile atomically:YES]; 	
	
	NSLog(@"%@",copy);
	 
	if (worked == false)
	{
		NSLog(@"unable to save library ..");
		
	}
	
	
}   

// :::::: Connectivity stuff 
////////////////////////////////////////////////////////////////
- (void) requestFinished:(ASIHTTPRequest *)request {
    NSString *response = [request responseString];
    // response contains the data returned from the server.
	
	NSLog(@"%@", response);
	
	//NSData *xmlData = [NSData response];
	NSData *xmlData = [response dataUsingEncoding:NSUTF8StringEncoding];

	NSXMLParser* parser = [[NSXMLParser alloc] initWithData:xmlData];
	
	[parser setDelegate:self];
	[parser parse];
	
}
- (void) requestFailed:(ASIHTTPRequest *)request {
    NSError *error = [request error];
    // Do something with the error.
}

// :::::: Library management
////////////////////////////////////////////////////////////////
- (NSArray*) getCurrentQuestionGroupsArray {
	// if we are at the root node ...
	if ([currentGroup length] == 0) // if the string is empty, show all groups ....
	{
		NSMutableArray *keys;
		keys = [[NSMutableArray alloc] initWithCapacity: [[libraryArray allKeys] count]];
		[keys addObjectsFromArray:[libraryArray allKeys]]; 		
		
		// SEPCIAL CASE ::::::
		// remove the timestamp (updated at)
		[keys removeObject:@"updatedTime"]; 		
		
		return keys; 
		// Aaron - memory leak ??
	}
	else // return an array showing just this Question Group ...
	{
		NSLog(@"key %@", currentGroup);
		
		NSMutableArray *currentSoundbites = [[NSMutableArray alloc] init];
		[currentSoundbites addObjectsFromArray:[libraryArray objectForKey:currentGroup]]; 		
		
		// reduce to a list of filenames .....
		NSMutableArray* names;
		names = [[NSMutableArray alloc] init];
		
		for (SoundBite *soundBite in currentSoundbites) {
		 	NSLog(@" q name: %@", [soundBite objectForKey:@"name"]);
			[names addObject:[soundBite objectForKey:@"name"]];
		}
		
		return names;
	}
	
	
	
}  
- (NSMutableArray*)getCurrentSoundBitesArray {
	
	NSMutableArray *currentSoundbites = [[NSMutableArray alloc] init];
	[currentSoundbites addObjectsFromArray:[libraryArray objectForKey:currentGroup]]; 		
	
	return currentSoundbites;
	
}

- (id) getCurrentSoundBite {
	return currentSoundbite;
}
- (void) setCurrentSoundbite:(SoundBite*) newCurrentSoundbite {

	NSLog(@"new soundbite set");
	currentSoundbite = newCurrentSoundbite;
}

- (NSString*) getCurrentQuestionGroupName {  
	// get the current question group ..... 
	return currentGroup;
}

- (void) createNewGroup:(NSString*) newGroupName {
	
	NSLog(@"library - adding new group: %@", newGroupName);
	NSMutableArray *newArray = [[NSMutableArray alloc] init];
	
	[libraryArray setObject:newArray forKey:newGroupName];
	
	// refresh ??
}
- (void) createNewSoundbite {
	
	NSLog(@"library - new soundbite");
	
	SoundBite *newSoundbite = [[SoundBite alloc] init];
	 
	//newSoundbite.fileName = [fileName copy];
	newSoundbite.parentQuestionOrSet = [self getCurrentQuestionGroupName];
	newSoundbite.questionName = @"some name"; 
	newSoundbite.comments = @"no comments";	
	
	// Pull up the appropriate question set (array) and add this
	// note *** if this is an answer ... the "questionset" is the questionID it maps too .....
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	[tempArray addObjectsFromArray:[libraryArray objectForKey:[self getCurrentQuestionGroupName]]]; // existing set
	[tempArray addObject:[newSoundbite getDictionary]]; // add the new one ....
	[libraryArray setObject:tempArray forKey:[self getCurrentQuestionGroupName]]; // set as the new set ...
	[tempArray release];
	
	[self setCurrentSoundbite:newSoundbite];
	
}

- (NSString*) getCurrentGroup {
	return currentGroup;
	
}
- (void) setCurrentGroup:(NSString*) newGroup {
	currentGroup = newGroup;
}


- (void) setQuestionName:(NSString*) newName
{
	
	NSLog(@"asdfasdfasf");
	currentSoundbite.questionName = @"testtttt";
	
}

@end
 