//
//  midiPlayerAppDelegate.m
//  midiPlayer
//
//  Created by Aaron Leese on 4/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "audioPlayerAppDelegate.h"

@implementation audioPlayerAppDelegate

@synthesize window;
@synthesize tabBarController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	NSLog(@"Init recorder");
	myAudioPlayer = [[audioPlayer alloc] init];
	
	NSLog(@"Init Downloader");
	downloader = [[downloadManager alloc] init];
	
	NSLog(@"Init Library");
	myLibrary = [[libraryManager alloc] init];
	
	NSLog(@"Init views");
	[window addSubview:tabBarController.view];

}
- (void)applicationWillTerminate:(UIApplication *)application{
	
	// save the library .... 
	[myLibrary saveLibrary];
	
}

// action sheet methods ... for review/save dialog ...
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	NSLog(@"action sheet button clicked");
	
    if (buttonIndex == 0) { 
		NSLog(@"review"); 
		[myAudioPlayer reviewRecorded];
		[self showReviewPanel];

    } else if (buttonIndex == 1) {
		// Rerecord ...
		NSLog(@"re record");
		[self startRecording];
    }
	else if (buttonIndex == 2) {
		// Sae ...
		NSLog(@"save answer");
    }
	else if (buttonIndex == 3) {
		// cancel ... do nothing
		NSLog(@"cancelled"); 
    }
}

- (void)dealloc {
	
    [tabBarController release];
    [window release];
	[myAudioPlayer release];
	[downloader release];
	[myLibrary release];
    [super dealloc];
}

- (void) startRecording{
	
	[myAudioPlayer startRecording];
	 
}
- (void) stopRecording{
	[myAudioPlayer stopRecording];
}

-(void) play:(NSString*) filePath {
	
	NSLog(@"trigger play");
	[myAudioPlayer play:filePath];
	
}

-(bool) isRecording
{
	return [myAudioPlayer isRecording];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag
{
	NSLog (@"audioRecorderDidFinishRecording:successfully:");
	 
	[self showReviewPanel];
	 
}

- (void)showReviewPanel
{
	UIActionSheet *popupQuery = [[UIActionSheet alloc]
								 initWithTitle:nil
								 delegate:self
								 cancelButtonTitle:@"Cancel"
								 destructiveButtonTitle:nil
								 otherButtonTitles:@"Review", @"Record", @"Save", nil];
	
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[popupQuery showInView:self.tabBarController.view];
	[popupQuery release];
	
}

- (NSString*) getCurrentQuestion
{
	return currentQuestion;
}
- (void) setCurrentQuestion : (NSString*) questionPath
{ 
	currentQuestion = questionPath;
}

- (void) triggerDownload:(NSURL*) newItem {
	[downloader triggerDownload:newItem];
}

- (void) refreshLibraryView
{
	NSLog(@"refresh Library View ...");
	[myLibraryView refreshLibraryView];
	
}


- (float) getInputLevel {
	
	return [myAudioPlayer getInputLevel];
}

- (NSMutableArray*) getLibrary
{ 
	return [myLibrary getLibraryArray];
}

@end

