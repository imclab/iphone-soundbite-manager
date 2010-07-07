//
//  libraryViewController.m
//
//  Created by Aaron Leese on 5/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
 
#import <Foundation/Foundation.h> 

NSArray* libraryArray;

#import "libraryViewController.h"
#import "audioPlayerAppDelegate.h"
#import "playViewController.h"

@implementation libraryViewController

@synthesize activityIndicator;

-(void)viewDidLoad
{	
	NSLog(@"lib View loading ...");
	
	CurrentGroup = @"";
	
	// init the library Array
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	libraryArray = [appDelegate getLibrary:@""];
}

- (void) refreshLibraryView
{ 
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	libraryArray = [appDelegate getLibrary:CurrentGroup];
	[self.view reloadData];
}

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
    
	// if currently viewing groups .... just refresh the view with a view of this group
	if ([CurrentGroup length] == 0)
	{
		CurrentGroup = [libraryArray objectAtIndex:indexPath.row]; //[[NSBundle mainBundle] pathForResource:testin ofType:@"mid"];
		[self refreshLibraryView];
		return;
	}
	
	
	// load the appropriate file to the midiPlayer
	NSString *fileName = [libraryArray objectAtIndex:indexPath.row]; //[[NSBundle mainBundle] pathForResource:testin ofType:@"mid"];
	NSString *dbFilePath = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:@"wav"];
	
	// since we have files in the main bundle, and ones that are downloaded to the doc folder ....
	if (dbFilePath.length == 0)
	{
		NSString *docDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/"];
		dbFilePath = [docDirectory stringByAppendingPathComponent:fileName];
	 
	}

	// start Playing ...
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate setCurrentQuestion:fileName];
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
  
@end
