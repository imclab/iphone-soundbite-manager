//
//  libraryViewController.m
//
//  Created by Aaron Leese on 5/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
 
#import <Foundation/Foundation.h> 

NSMutableArray* libraryArray;

#import "libraryViewController.h"
#import "audioPlayerAppDelegate.h"

@implementation libraryViewController

@synthesize activityIndicator;

-(void)viewDidLoad
{	
	// init the library Array
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];

	libraryArray = [appDelegate getLibrary];
}

- (void) refreshLibraryView
{ 
	[self.view reloadData];
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [libraryArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.textLabel.text = [[[libraryArray objectAtIndex:indexPath.row] lastPathComponent] stringByDeletingPathExtension];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	// load the appropriate file to the midiPlayer
	NSString *fileName = [libraryArray objectAtIndex:indexPath.row]; //[[NSBundle mainBundle] pathForResource:testin ofType:@"mid"];
	
	// if ([fileManager fileExistsAtPath:filePath]) {
	
	NSString *dbFilePath = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:@"wav"];
	 
	
	// since we have files in the main bundle, and ones that are downloaded to the doc folder ....
	if (dbFilePath.length == 0)
	{
		NSString *docDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/"];
		dbFilePath = [docDirectory stringByAppendingPathComponent:fileName];
	 
	}
	

	// start Playing ...
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate setCurrentQuestion:dbFilePath];
	[appDelegate play:dbFilePath];
	
	// switch view ....
	[tabBar setSelectedIndex:1];

	/*
	 playViewController *detailViewController = [[playViewController alloc] initWithNibName:@"test" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	 
}
 
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
		
		//NSString *newitem = [attributeDict objectForKey:@"name"]; 
		
		NSString *path =  [attributeDict objectForKey:@"id"]; 
		
		// intuit the path from the filename for now ....
		NSString *filePath = @"http://www.flyloops.com/iphone/questions/";
		filePath = [filePath stringByAppendingString:path];
		
		NSURL *test = [NSURL URLWithString:filePath];
		
		NSLog(@"asasdasd %@", test);
		
		// if this is a question that is not in the local library already, download and add it ....
		if ([[filePath pathExtension] isEqualToString: @"wav"])
		{
			NSLog(@"added %@", filePath); 	
			
			//downloader 
			audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
			
			[appDelegate triggerDownload:test];
			
			//[libraryArray addObject:newitem];
		}
		
		
	}		
	
	
}

@end
