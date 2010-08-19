//
//  audioPlayer.m
//  audioPlayer
//
//  Created by Aaron Leese on 6/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "audioPlayer.h"

#import "audioPlayerAppDelegate.h"

@implementation audioPlayer

@synthesize currentQuestionFile;
@synthesize recorderFilePath;

-(id) init {
	
	audioSession = [AVAudioSession sharedInstance];
	NSError *err = nil;
	[audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
	if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        //return;
	}
	[audioSession setActive:YES error:&err];
	err = nil;
	if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        //return;
	}
	
	playBackVolume = 1;
	
	NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
	
	//	[recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
	[recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey]; 
	[recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
	
	[recordSetting setValue :[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
	[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
	[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
	
	
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	NSString *seconds = [NSString stringWithFormat:@"%qu", now]; 
	
	recorderFilePath = [[NSString stringWithFormat:@"%@/%@.caf", DOCUMENTS_FOLDER, seconds] retain];
	
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
        //return;
		
	}
	
	return self;
	
}

// RECORD / PLAY
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
- (void) reviewRecorded {
	
	[self play:recorderFilePath];
	
}
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag {
	NSLog (@"audioRecorderDidFinishRecording:successfully:");
	
	audioPlayerAppDelegate *appDelegate = (audioPlayerAppDelegate *)[[UIApplication sharedApplication] delegate];
	[appDelegate showReviewPanel];
	
}
- (void) play:(NSString*) filePath {
	
	NSLog(@"play %@",filePath);
	
	//return;
	NSString *soundFilePath = filePath;// [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav" inDirectory:@"audio files"];
	NSURL *soundFileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
	
	[appSoundPlayer release];
	 appSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: soundFileURL error: nil];
	[appSoundPlayer prepareToPlay];
	[appSoundPlayer setMeteringEnabled: YES];
    [appSoundPlayer setVolume:playBackVolume];
	[appSoundPlayer play];
	 
	
}

// PROPERTIES
-(bool) isRecording {
	return recorder.recording;
}
-(bool) isPlaying {
	
	return [appSoundPlayer isPlaying];
}
- (void) setPlaybackVolume:(float) newVolume {
	NSLog(@"volume changed: %f", newVolume);
	[appSoundPlayer setVolume:newVolume];
	playBackVolume = newVolume;
}
- (float) getInputLevel {
	[recorder updateMeters];
	 return ([recorder averagePowerForChannel:0] +[recorder averagePowerForChannel:1]);
}
- (float) getOutputLevel {
	[appSoundPlayer updateMeters];
	
	//NSLog(@"output %f", playBackVolume*([appSoundPlayer averagePowerForChannel:0]+[appSoundPlayer averagePowerForChannel:1]));
		  
	return (playBackVolume*([appSoundPlayer averagePowerForChannel:0]+[appSoundPlayer averagePowerForChannel:1]));
}

@end

