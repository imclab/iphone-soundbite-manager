//
//  midiPlayerAppDelegate.h
//  midiPlayer
//
//  Created by Aaron Leese on 4/27/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h> 
#import "downloadViewController.h"
#import "libraryManager.h"
#import "audioPlayer.h"

@interface audioPlayerAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
 
	NSString *currentQuestion;
	
	IBOutlet downloadViewController *downloader;
	
	// custom classed objects ...
	libraryManager *myLibrary;
	audioPlayer *myAudioPlayer;
	

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

//- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *) aRecorder successfully:(BOOL)flag;
- (void) startRecording;
- (void) stopRecording;
- (void) play:(NSString*)fileName; 
- (bool) isRecording;
- (float) getInputLevel;

- (NSString *) getCurrentQuestion;

- (void) triggerDownload:(NSURL*) newItem;
- (NSMutableArray*) getLibrary;
@end
