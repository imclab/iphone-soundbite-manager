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
    
	NSLog(@"App init code");
	
	NSLog(@"Init recorder");
	//////////////////////////////////////////////////
	
	audioSession = [AVAudioSession sharedInstance];
	NSError *err = nil;
	[audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
	if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
	}
	[audioSession setActive:YES error:&err];
	err = nil;
	if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
	}
	
	
	NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
	
	//	[recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
	[recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey]; 
	[recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
	
	[recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
	[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
	[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
	
	
	// Create a new dated file
	NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
	NSString *caldate = [now description];
	
	recorderFilePath = [[NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, caldate] retain];
	
	NSURL *url = [NSURL fileURLWithPath:recorderFilePath];
	err = nil;
	
	// recorder
	recorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSetting error:&err];
	
	if(!recorder){
        NSLog(@"recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
								   message: [err localizedDescription]
								  delegate: nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
	}
	
	
	NSLog(@"Init Library");
	myLibrary = [[libraryManager alloc] init];
	
	NSLog(@"Init views");
	[window addSubview:tabBarController.view];

}

- (void)applicationWillTerminate:(UIApplication *)application{
	
	// save the library ....
	
}

// action sheet methods ... for review/save dialog ...
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	NSLog(@"action sheet button clicked");
	
    if (buttonIndex == 0) { 
		NSLog(@"review"); 
		[self play:recorderFilePath];
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
	[myLibrary release];
    [super dealloc];
}

- (void) startRecording{
	
	//prepare to record
	[recorder setDelegate:self];
	[recorder prepareToRecord];
	recorder.meteringEnabled = YES;
	
	BOOL audioHWAvailable = audioSession.inputIsAvailable;
	if (! audioHWAvailable) {
        UIAlertView *cantRecordAlert =
        [[UIAlertView alloc] initWithTitle: @"Warning"
								   message: @"Audio input hardware not available"
								  delegate: nil
						 cancelButtonTitle:@"OK"
						 otherButtonTitles:nil];
        [cantRecordAlert show];
        [cantRecordAlert release]; 
        return;
	}
	
	// start recording
	[recorder record];
	 
}

- (void) stopRecording{
	
	[recorder stop];
	
	NSURL *url = [NSURL fileURLWithPath: recorderFilePath];
	NSError *err = nil;
	NSData *audioData = [NSData dataWithContentsOfFile:[url path] options: 0 error:&err];
	if(!audioData)
        NSLog(@"audio data: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
	
	//[audioData setValue:[NSData dataWithContentsOfURL:url] forKey:editedFieldKey];       
	//[recorder deleteRecording];
	
	// remove the file ...
	//NSFileManager *fm = [NSFileManager defaultManager];
	//err = nil;
	//[fm removeItemAtPath:[url path] error:&err];
	//if(err)
	//  NSLog(@"File Manager: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
	
	NSLog(@"File Recorded To: %@",recorderFilePath);
	
	// place it in a temp file ??? , and trigger modal dialog / review ....
	
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

-(void) play:(NSString*) filePath {
	
	NSLog(@"play %@",filePath);
	
	//return;
	NSString *soundFilePath = filePath;// [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav" inDirectory:@"audio files"];
	NSURL *soundFileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
	 
    //NSError *activationError = nil;
    //[[AVAudioSession sharedInstance] setActive: YES error: &activationError];
	
    AVAudioPlayer *appSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: soundFileURL error: nil];
	[appSoundPlayer prepareToPlay];
    [appSoundPlayer setVolume: 1.0];
	[appSoundPlayer play];
	
}

-(bool) isRecording
{
	return recorder.recording;
}

- (NSString*) getCurrentQuestion
{
	return currentQuestion;
}

- (void) setCurrentQuestion : (NSString*) questionPath
{ 
	currentQuestion = questionPath;
}

- (void) triggerDownload:(NSURL*) newItem
{
	[downloader triggerDownload:newItem];
}

- (float) getInputLevel
{

	[recorder updateMeters];
	//NSLog(@"Peak Power : %f , %f", [recorder peakPowerForChannel:0], [recorder peakPowerForChannel:1]);
	//NSLog(@"Average Power : %f , %f", [recorder averagePowerForChannel:0], [recorder averagePowerForChannel:1]);
	return ([recorder averagePowerForChannel:0] +[recorder averagePowerForChannel:1]);
	
}

- (NSMutableArray*) getLibrary
{ 
	return [myLibrary getLibraryArray];
}

@end

