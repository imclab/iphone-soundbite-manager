//
//  midiPlayerAppDelegate.m
//  midiPlayer
//
//  Created by Aaron Leese on 4/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "audioPlayerAppDelegate.h"

@implementation audioPlayerAppDelegate

@synthesize CurrentQuestionID;
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
	
	
	NSLog(@"closing");
	
	  		 
	UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Error" message:   
							  @"testing"
							  delegate:self cancelButtonTitle:@"OK" 
							  otherButtonTitles:nil, nil];
	[alert show];
	[alert release];
		
		//return;
	
	// save the library .... 
	[myLibrary saveLibrary];
	
}
- (void)dealloc {
	
    [tabBarController release];
    [window release];
	[myAudioPlayer release];
	[downloader release];
	[myLibrary release];
    [super dealloc];
}

// ACTION SHEET methods ... for review/save dialog ...
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
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
		NSLog(@"upload the answer");
		
		[downloader uploadAnswer];
		
    }
	else if (buttonIndex == 3) {
		// cancel ... do nothing
		NSLog(@"cancelled"); 
    }
}
- (void)showReviewPanel {
	UIActionSheet *popupQuery = [[UIActionSheet alloc]
								 initWithTitle:nil
								 delegate:self
								 cancelButtonTitle:@"Cancel"
								 destructiveButtonTitle:nil
								 otherButtonTitles:@"Review", @"Record", @"Upload", nil];
	
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[popupQuery showInView:self.tabBarController.view];
	[popupQuery release];
	
}

// AUDIO :::::::::
- (void) startRecording{
	
	[myAudioPlayer startRecording];
	 
}
- (void) stopRecording{

	[myAudioPlayer stopRecording];
}
- (void) play:(NSString*) filePath {
	
	NSLog(@"trigger play");
	[myAudioPlayer play:filePath];
	
}
- (bool) isRecording {
	
	return [myAudioPlayer isRecording];
}
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag {
	NSLog (@"audioRecorderDidFinishRecording:successfully:");
	 
	[self showReviewPanel];
	 
}
- (void) setVolume:(float)newVolume {
	
	[myAudioPlayer setPlaybackVolume:newVolume];	
}
- (float) getInputOrOutputLevel {
	
	
	if ([myAudioPlayer isPlaying])
	{
		return [myAudioPlayer getOutputLevel];
	}
	else // ([myAudioPlayer isRecording])
	{
		return [myAudioPlayer getInputLevel];
	}
	
	//else return float(-20.0);
	
	
	
}

// DOWNLOAD / UPLOAD ::::::::
- (void) triggerDownload:(NSURL*) newItem {
	[downloader triggerDownload:newItem];
}
- (void) refreshLibraryView {
	NSLog(@"refresh Library View ...");
	[myLibraryView refreshLibraryView];
	
}


// CUSTOM GETTER/SETTER s :::::
- (NSArray*) getCurrentQuestionGroup {  
	// get the current question group .....
	return [myLibrary getCurrentQuestionGroupArray];
}

- (void) setCurrentQuestionGroup:(NSString*) newGroup {  
	// set the current question group .....
	NSLog(@"setting new Group: %@", newGroup);
	[myLibrary setCurrentGroup:(NSString*) newGroup];
}



- (NSString*) getCurrentQuestionFile {
	return myAudioPlayer.currentQuestionFile;
}
- (NSString*) getRecordedToPath {
	return myAudioPlayer.recorderFilePath;
}
- (void) setCurrentQuestion : (NSString*) path  withID:(NSString*)sqlID { 
	
	// set the file, so the audioPlayer kows what to play 
	myAudioPlayer.currentQuestionFile = path;
	
	// set the ID, so the downloader / uploader knows whasqlID to use ...
	CurrentQuestionID = sqlID;
	
}
- (NSMutableArray*) getSoundBiteArray {
	
	[myLibrary getCurrentSoundBiteArray];
	
}


-(SoundBite*) getCurrentSoundbite {
	return [myLibrary getCurrentSoundBite];
}

- (void) setCurrentSoundbite:(SoundBite*) currentSoundbite
{
		[myLibrary setCurrentSoundbite:currentSoundbite];
}

@end

