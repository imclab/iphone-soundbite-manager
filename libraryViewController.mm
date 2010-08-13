//
//  libraryViewController.m
//
//  Created by Aaron Leese on 5/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
 
#import <Foundation/Foundation.h> 

#import "libraryManager.h"
NSArray* libraryArray;

#import "libraryViewController.h"

#import "audioPlayerAppDelegate.h"
#import "playViewController.h"

@implementation libraryViewController

@synthesize activityIndicator;

-(void)viewDidLoad
{	
	NSLog(@"lib View loading ...");
	
	// init the library Array
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	libraryArray = [appDelegate getCurrentQuestionGroup];
	
	questionSetview = [[QuestionSetView alloc] init];
	
	[self refreshLibraryView];
}

-(void)viewDidAppear:(BOOL)animated 
{
	
	NSLog(@"lib View appearing ...");
	
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[appDelegate setCurrentQuestionGroup:@""];
	
	[self refreshLibraryView];
	
}

- (void) refreshLibraryView
{ 
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	libraryArray = [appDelegate getCurrentQuestionGroup];
	
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
    
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	
	// if currently viewing groups .... just refresh the view with a view of this group
	
	// always teh case now .... since we have two controllers .
	//if ([CurrentGroup length] == 0)
	//{
	//	CurrentGroup = [libraryArray objectAtIndex:indexPath.row]; //[[NSBundle mainBundle] pathForResource:testin ofType:@"mid"];
		
	[appDelegate setCurrentQuestionGroup:[libraryArray objectAtIndex:indexPath.row]];
		
	
   // questionSetview.title = [appDelegate getCurrentQuestionGroupName];
	
	
//    newQuestionSet.location = location;
  //  newQuestionSet.delegate = delegate;

	
	//UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"flip", @"flip") style:UIBarButtonItemStylePlain target:self action:@selector(flip)];
	//[questionSetview setRightBarButtonItem: barButton];
	
	
	[self.navigationController pushViewController:questionSetview animated:YES]; 

	
	 
	
	
		//[self refreshLibraryView];
		return;
	//}
	
	NSMutableArray *currentSoundbites = [[NSMutableArray alloc] init];
	[currentSoundbites addObjectsFromArray:[appDelegate getSoundBiteArray]]; 		
	
	SoundBite *current = [[SoundBite alloc] init];
	current = [currentSoundbites objectAtIndex:indexPath.row];
	
	NSLog(@"current %@", [current sqlID]);
	[appDelegate setCurrentSoundbite:current];
	
	// load the appropriate file to the midiPlayer
	NSString *fileName = [libraryArray objectAtIndex:indexPath.row]; //[[NSBundle mainBundle] pathForResource:testin ofType:@"mid"];
	NSString *dbFilePath = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:@"wav"];
	
	// since we have files in the main bundle, and ones that are downloaded to the doc folder ....
	if (dbFilePath.length == 0)
	{
		NSString *docDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/"];
		dbFilePath = [docDirectory stringByAppendingPathComponent:fileName];
	 
	}

	// set the filename, which is used to tell te player what to play
	[appDelegate setCurrentQuestion:fileName withID:[current sqlID]];
	
	// also set the currentID .... in case we need to upload .... 	
	[appDelegate play:dbFilePath];
	
	// switch view ....
	//[tabBar setSelectedIndex:1];
	//playViewController* test = [[playViewController alloc] init];
	//[self.navigationController pushViewController:test animated:YES]; 
	
	
}
 
@end
