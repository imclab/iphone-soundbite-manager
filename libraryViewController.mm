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
 
#import "groupModal.h"

@implementation libraryViewController
 
-(void)viewDidLoad {	
	NSLog(@"lib View loading ...");
	
	// init the library Array
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	libraryArray = [appDelegate getCurrentQuestionGroup];
	
	questionSetview = [[QuestionSetView alloc] init];
	
	[self refreshLibraryView];
}
-(void)viewDidAppear:(BOOL)animated {
	
	NSLog(@"lib View appearing ...");
	
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	
	[appDelegate setCurrentQuestionGroup:@""];
	
	[self refreshLibraryView];
	
}
- (void)refreshLibraryView { 
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
    
	// A question Group was just selected ... set it in the library, and switch views ...
	
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];	 
	[appDelegate setCurrentQuestionGroup:[libraryArray objectAtIndex:indexPath.row]];
	[self.navigationController pushViewController:questionSetview animated:YES]; 

}
-(IBAction) newQuestionGroup:(id)sender {
	NSLog(@"add new Question Group");
		  
	[self presentModalViewController:[[groupModal alloc]init] animated:YES];

}


@end
