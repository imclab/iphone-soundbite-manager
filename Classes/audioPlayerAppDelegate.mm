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

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	NSLog(@"Init recorder");
	myAudioPlayer = [[audioPlayer alloc] init];
	
	NSLog(@"Init Downloader");
	downloader = [[downloadManager alloc] init];
	
	NSLog(@"Init Library");
	myLibrary = [[libraryManager alloc] init];
	
	NSLog(@"Init views");
	//[window addSubview:tabBarController.view];

}
- (void) applicationWillResignActive:(UIApplication *)application {
	
	//[self applicationWillTerminate:application];
	[myLibrary saveLibrary];
}

- (void)applicationWillTerminate:(UIApplication *)application{
	
	NSLog(@"closing");
	
}
- (void)dealloc {
	
	[window release];
	[myAudioPlayer release];
	[downloader release];
	[myLibrary release];
    [super dealloc];
}
 
// AUDIO :::::::::
- (void) startRecording{
	
	[myAudioPlayer startRecording];
	 
}
- (void) stopRecording{

	[myAudioPlayer stopRecording];
}
- (void) reviewRecorded {
	[myAudioPlayer reviewRecorded];
}
- (void) play:(NSString*) filePath {
	
	NSLog(@"trigger play");
	[myAudioPlayer play:filePath];
	
}
- (bool) isRecording {
	
	return [myAudioPlayer isRecording];
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
- (void) uploadAnswer {
	
	[downloader uploadAnswer];
}
- (void) saveSoundbiteToLibrary {
	
	// whatever the current soundbite is
	
	
}

// CUSTOM GETTER/SETTER :::::
- (NSArray*) getCurrentQuestionGroup {  
	// get the current question group .....
	return [myLibrary getCurrentQuestionGroupsArray];
}
- (NSString*) getCurrentQuestionGroupName {  
	// get the current question group ..... 
	return [myLibrary getCurrentQuestionGroupName];
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
	
	[myLibrary getCurrentSoundBitesArray];
	
}
-(SoundBite*) getCurrentSoundbite {
	return [myLibrary getCurrentSoundBite];
}
- (void) setCurrentSoundbite:(SoundBite*) currentSoundbite {
		[myLibrary setCurrentSoundbite:currentSoundbite];
	 
}

- (void) createQuestionGroup:(NSString*) newGroupName {
	NSLog(@"app del - create new group");
	
	[myLibrary createNewGroup:newGroupName];
	
}
- (void) createNewSoundbite {
	NSLog(@"app del - create new question");
	
	[myLibrary createNewSoundbite];
	
}



- (void) setQuestionName:(NSString*) newName
{
	NSLog(@"changing q name");
	[myLibrary setQuestionName:newName];
	 
}





@end

