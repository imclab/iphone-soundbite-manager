//
//  audioPlayer.h
//  audioPlayer
//
//  Created by Aaron Leese on 6/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]


@interface audioPlayer : NSObject {

	AVAudioSession *audioSession;
    AVAudioRecorder *recorder;
	NSString *recorderFilePath; 
	NSString *currentQuestion;
	
	
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag;
- (void) startRecording;
- (void) stopRecording;
- (void) play:(NSString*)fileName; 
- (bool) isRecording;

- (void) reviewRecorded;


- (float) getInputLevel;

//- (NSString *) getCurrentQuestion;


@end
