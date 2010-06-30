//
//  midiPlayerAppDelegate.h
//  midiPlayer
//
//  Created by Aaron Leese on 4/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]

#import "downloadViewController.h"
#import "libraryManager.h"

@interface audioPlayerAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
 
	AVAudioSession *audioSession;
    AVAudioRecorder *recorder;
	NSString *recorderFilePath; 
	NSString *currentQuestion;
	
	IBOutlet downloadViewController *downloader;
	
	libraryManager *myLibrary;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag;
- (void) startRecording;
- (void) stopRecording;
- (void) play:(NSString*)fileName; 
- (bool) isRecording;
- (NSString *) getCurrentQuestion;

- (void) triggerDownload:(NSURL*) newItem;

- (NSMutableArray*) getLibrary;

- (float) getInputLevel;

@end
