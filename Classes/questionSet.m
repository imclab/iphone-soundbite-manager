//
//  libraryViewController.m
//
//  Created by Aaron Leese on 5/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h> 

#import "libraryManager.h"
NSArray* questionNamesArray;

#import "QuestionSet.h"
#import "audioPlayerAppDelegate.h"
#import "playViewController.h"

#import "newQuestionModal.h"

@implementation QuestionSetView

@synthesize activityIndicator;
@synthesize myNavItem;

-(void)viewDidLoad
{	
	NSLog(@"lib View loading ...");
	
	// Set the Right nav bar button ....
	newQuestionButton = [[[UIBarButtonItem alloc] 
										   initWithTitle:@"new question" style:UIBarButtonItemStyleBordered
										   target:self 
										   action:@selector(newQuestion)] autorelease];
	
	self.navigationItem.rightBarButtonItem = newQuestionButton;
	
	// init the library Array
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	questionNamesArray = [appDelegate getCurrentQuestionGroup];
	
	[self refreshLibraryView];
}

-(void)viewDidAppear:(BOOL)animated 
{
	
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	 
	NSLog(@"q set view appearing ...");
	 
	[self refreshLibraryView];
	
	self.title =  [appDelegate getCurrentQuestionGroupName]; 
	
}

- (void) refreshLibraryView
{ 
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	questionNamesArray = [appDelegate getCurrentQuestionGroup];
	[self.view reloadData];
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [questionNamesArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	cell.textLabel.text = [[[questionNamesArray objectAtIndex:indexPath.row] lastPathComponent] stringByDeletingPathExtension];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	NSMutableArray *currentSoundbites = [[NSMutableArray alloc] init];
	[currentSoundbites addObjectsFromArray:[appDelegate getSoundBiteArray]]; 		
	
	SoundBite *current = [[SoundBite alloc] init];
	current = [currentSoundbites objectAtIndex:indexPath.row]; // custom copy routine .... should get all fields ...
	
	NSLog(@"current %@", [current objectForKey:@"sqlID"]);
	[appDelegate setCurrentSoundbite:current];
	
	// load the appropriate file to the midiPlayer
	NSString *fileName = [questionNamesArray objectAtIndex:indexPath.row]; //[[NSBundle mainBundle] pathForResource:testin ofType:@"mid"];
	NSString *dbFilePath = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:@"wav"];
	
	// since we have files in the main bundle, and ones that are downloaded to the doc folder ....
	if (dbFilePath.length == 0)
	{
		NSString *docDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/"];
		dbFilePath = [docDirectory stringByAppendingPathComponent:fileName];
		
	}
	
	// set the filename, which is used to tell te player what to play
	[appDelegate setCurrentQuestion:fileName withID:[current objectForKey:@"sqlID"]];
	
	// also set the currentID .... in case we need to upload .... 	
	[appDelegate play:dbFilePath];
	
	// switch view .... 
	playViewController* player = [[playViewController alloc] init];
	[self.navigationController pushViewController:player animated:YES]; 
	
	
}

- (void) newQuestion {
	
	NSLog(@"new question button clicked");
	
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	// add a new soundbite to the library ...
	[appDelegate createNewSoundbite];
	
	// this will set the question name (using the currentQ)
	[self presentModalViewController:[[newQuestionModal alloc]init] animated:YES];
	
	
	
	// switch view .... 
	//playViewController* playView = [[playViewController alloc] init];
	//[self.navigationController pushViewController:playView animated:YES]; 
	
	
	
}
 
@end
